//
//  InvoiceBot.swift
//  InVoice
//
//  Created by Richard Marktl on 13.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import Horreum
import Speech
import AVKit
import RxSwift

// swiftlint:disable file_length
enum InvoiceBotState: Equatable {
    case none
    case cancelled
    case textEditing
    case replay(VoiceAction)
}

enum InvoiceBotResult: Equatable {
    case invoice
    case offer
}

func == (lhs: InvoiceBotState, rhs: InvoiceBotState) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.cancelled, .cancelled):
        return true
    case (.textEditing, .textEditing):
        return true
    case (.replay(let action1), .replay(let action2)):
        return action1 === action2
    default:
        return false
    }
}

protocol InvoiceBotDelegate: class {
    func bot(_ bot: InVoiceBot, show action: VoiceAction, removed range: CountableClosedRange<Int>?)
    func bot(_ bot: InVoiceBot, removed range: CountableClosedRange<Int>?)
    func bot(_ bot: InVoiceBot, isActionRepeatable: Bool)
    func bot(_ bot: InVoiceBot, failed: Error)
}

/// The class InvoiceBot contains the logic to create a invoice using sound input. The delegate should be used to accompany
/// the creation with visual elements.
///
/// The Voice Input is created through VoiceAction class objects. The action handles one element of the invoice input
/// like play a sound or wait for a input.
/// Example: Add the customer.
/// 1. Action: Play "Who should receive your invoice?"
/// 2. Action: Listen to Input => process the input and based on the result play the next action.
/// 3.1. Action: customer not found => try to create a new one or repeat the input
/// 3.2. Action: costumer found => add it to the invoice and go to the item section
/// 3.3. Action: multiple costumers found => next action select the right customer
///
/// The Voice Input is handled as temporary child. An action that needs voice input will return the user an InputVoice
/// action. This action will be used to collect the voice data. If the data is collected this child will be replaced
/// by a real child like ClientFoundVoiceAction.

// swiftlint:disable type_body_length
class InVoiceBot {
    public var actions: [VoiceAction] = []
    private var _state: InvoiceBotState = .none
    
    public internal(set) var state: InvoiceBotState {
        get { return _state }
        set { if _state != .cancelled { _state = newValue } }
    }
    
    /// This variable contains the current active action
    public internal(set) var action: VoiceAction
    public weak var delegate: InvoiceBotDelegate?
    
    private var config: VoiceActionConfig
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale.current)!
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var recordingSubject = PublishSubject<(VoiceAction?, Bool)>()
    public var recording: Observable<(VoiceAction?, Bool)> {
        return recordingSubject.asObservable()
    }
    
    private var voiceInputSubject = PublishSubject<VoiceAction>()
    public var voiceInput: Observable<VoiceAction> {
        return voiceInputSubject.asObservable()
    }
    
    init(result type: InvoiceBotResult = .invoice) {
        
        config = VoiceActionConfig(
            childContext: Horreum.instance!.childContext(),
            result: type
        )
        
        action = AddClientVoiceAction(parent: nil, config: config)
        logger.debug("InVoice Bot initialized with locale: \(recognizer.locale)")
    }
    
    /// This method will ask for the user permission and if granted also start the invoice bot.
    public func askSpeechPermission() {
        logger.debug("InvoiceBot SFSpeechRecognizer request authorization.")
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation { // run this always on the main thread
                switch authStatus {
                case .authorized:
                    self.start()
                case .denied:
                    self.failed(with: R.string.localizable.accessDenied())
                case .restricted:
                    self.failed(with: R.string.localizable.accessRestricted())
                case .notDetermined:
                    self.failed(with: R.string.localizable.notAuthorized())
                }
            }
        }
    }
    
    /// This method will force the bot the process the current voice input result. Useful for buttons.
    public func tryToProcessInput() {
        if action.voiceInput?.isEmpty == false {
            stopRecording()
        }
    }
    
    /// This method will cancel the invoice bot.
    public func cancel() {
        state = .cancelled
        speechSynthesizer.stopSpeaking(at: .immediate)
        stopRecording()
    }
    
    /// This method will iterate through the actions and then fill and save the new invoice.
    public func save() -> Job {
        let job = config.result == .invoice ? Invoice.create(in: config.childContext) : Offer.create(in: config.childContext)
        for action in actions {
            if let clientAction = action as? ClientFoundVoiceAction {
                job.client = clientAction.client
                job.update(from: clientAction.client)
            }
            
            if let orderAction = action as? OrderVoiceAction {
                orderAction.order.calculateTotal()
                orderAction.order.update(job: job)
            }
            
            job.total = BalanceModel.balance(for: job).total
            job.paymentDetails = Account.current().paymentDetails
            job.note = Account.current().note
        }
        try? config.childContext.save()
        return job
    }
    
    // This method will replay the last action able to do so.
    public func replay() {
        if let replayAction = action.repeatableParent {
            state = InvoiceBotState.replay(replayAction)
            speechSynthesizer.stopSpeaking(at: .immediate)
            if recognitionTask != nil {
                stopRecording()
            } else {
                reprocess(action: replayAction)
            }
        }
    }
    
    public func startTextEditing() {
        state = .textEditing
        stopRecording()
    }
    
    public func stopTextEditing() {
        state = .none
        if let parent = action.parent {
            parent.voiceInput = action.voiceInput
            handle(action: parent.processInput())
        }
    }
    
    private func initializeAudioSession() {
        do {
            logger.debug("InvoiceBot AVAudioSession initialization")
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            self.failed(with: R.string.localizable.recognitionError())
        }
    }
    
    /// This method will start the invoice bot voice input process.
    private func start() {
        initializeAudioSession()
        if recognizer.isAvailable {
            handle(action: action)
        } else {
            // maybe we should make the error not cancel able
            self.failed(with: R.string.localizable.recognitionError())
        }
    }
    
    /// The method process is used to unify the action result handling, it will either start the voice input mode
    /// or the visual input mode. The method is called after the voice output or immediately.
    ///
    /// - Parameter action: The action to process.
    private func process(action: VoiceAction) {
        if state == .cancelled {
            return
        }
        
        if action.needsVoiceInput {
            startRecording(action: action)
            // so it is possible that the user also ends the action by clicking on an item
            if let subject = action.touchInputSubject {
                _ = subject.take(1).subscribe(onNext: { (_) in
                    self.stopRecording() // the call will trigger the handle action call in the recognizer task
                })
            }
        } else {
            if let subject = action.touchInputSubject {
                _ = subject.take(1).subscribe(onNext: { (_) in
                    self.handle(action: action.processInput())
                })
            } else {
                handle(action: action.processInput())
            }
        }
    }
    
    /// This method will handle the voice input
    ///
    /// - Parameter action: the action is used to collect the voice input
    private func startRecording(action: VoiceAction) {
        // Cancel the previous task if it's running.
        if let task = recognitionTask {
            task.cancel()
            recognitionTask = nil
        }
        
        logger.error("start recording for: \(action)")
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = request else {
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // add the input voice action
        let inputAction = InputVoiceAction(parent: action)
        append(inputAction)
        delegate?.bot(self, show: inputAction, removed: nil)
        
        recognitionRequest.taskHint = .search  // this should be set by the action item
        recordingSubject.onNext((action, true))
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                logger.debug("voice input: \(result.bestTranscription.formattedString)")
                isFinal = result.isFinal
                action.voiceInput = result.bestTranscription.formattedString
                inputAction.voiceInput = result.bestTranscription.formattedString
                self.voiceInputSubject.onNext(inputAction)
            }
            
            // if the view was cancelled stop everything.
            switch self.state {
            case .cancelled, .textEditing:
                self.stopRecording()
            case .replay(let replayAction):
                DispatchQueue.main.async { self.reprocess(action: replayAction)}
            case .none:
                if error != nil || isFinal {
                    logger.debug("Recording - isFinal: \(isFinal), error \(String(describing: error))")
                    self.stopRecording()
                    self.handle(action: action.processInput())
                }
            }
        }
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: audioEngine.inputNode.outputFormat(forBus: 0)) { (buffer: AVAudioPCMBuffer, _: AVAudioTime) in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.failed(with: R.string.localizable.audioError())
        }
    }
    
    /// This method will stop the recording.
    private func stopRecording() {
        logger.debug("stopRecording called")
        if audioEngine.isRunning == false {
            return
        }
        recordingSubject.onNext((nil, false))
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        
        // this will cause isFinal to be true in the next call of the recognition task
        recognitionTask?.finish()
        recognitionTask = nil
    }
    
    /// This method will create an action item and this item will contain the error message.
    ///
    /// - Parameter error: the error message
    private func failed(with error: String) {
        append(ErrorVoiceAction(parent: action, message: error))
        delegate?.bot(self, failed: error)
    }
    
    /// This method will add the action output to the view.
    ///
    /// - Parameter action: the action contains what to speak and what to show
    private func handle(action: VoiceAction) {
        // if the same action is reused, return and end the method
        if action === actions.last || state == .cancelled {
            return
        }
        
        append(action)
        delegate?.bot(self, isActionRepeatable: action.hasRepeatableParent)
        delegate?.bot(self, show: action, removed: removeTypes(until: action))
        play(action: action)
    }
    
    /// This function is called by the repeat/cancel actions to force a new input for a repeatable action.
    ///
    /// - Parameter action: The action to replay.
    private func reprocess(action: VoiceAction) {
        logger.debug("reprocess action: \(action)")
        state = .none
        action.replay()
        
        delegate?.bot(self, removed: remove(until: action))
        delegate?.bot(self, isActionRepeatable: action.hasRepeatableParent)
        process(action: action)
    }
    
    /// This method will play the given question.
    ///
    /// - Parameter action: contains the question to play
    private func play(action: VoiceAction ) {
        logger.error("outputVoice called, with: \(action)")
        
        if action.voiceOutput.isEmpty == false {
            let speechUtterance = AVSpeechUtterance(string: action.voiceOutput)
            _ = speechSynthesizer.rx.didFinishSpeechUtterance.take(1).subscribe(onNext: { (_) in
                // check if the action was cancelled if yes don't perform the process action.
                if self.actions.contains(action) {
                    self.process(action: action)
                }
            })
            
            speechSynthesizer.speak(speechUtterance)
        } else {
            process(action: action)
        }
    }
    
    /// The method append will add the action to actions and also update the action property.
    ///
    /// - Parameter action: the action to update
    private func append(_ action: VoiceAction) {
        self.actions.append(action)
        self.action = action
    }
    
    /// This method will remove all action until the action contained in the removeUntil
    /// property of the VoiceAction. This functionality is needed to remove superfluous actions
    /// that were needed during the voice input process.
    /// For example: A new client needs 3 Input fields, and after it was created only one
    ///              client voice action. So we need to remove the others.
    /// In the case the removeUntil property is empty or the action is not found nothing is removed.
    ///
    /// - Parameter action: the action
    /// - Returns: nil or the removed range
    private func removeTypes(until action: VoiceAction) -> CountableClosedRange<Int>? {
        if let range = rangeToRemove(from: action) {
            actions.removeSubrange(range)
            return range
        }
        return nil
    }
    
    /// This method will remove all action until the parent was found.
    ///
    /// - Parameter parent: The search parameter
    /// - Returns: nit or the removed range.
    private func remove(until action: VoiceAction) -> CountableClosedRange<Int>? {
        if let index = actions.index(of: action) {
            let range = index+1...actions.count-1
            actions[range].forEach({ (action) in
                action.prepareDeletion()
            })
            actions.removeSubrange(range)
            return range
        }
        return nil
    }
    
    /// This method will check range of the actions to be removed.
    ///
    /// - Parameter action: an action object
    /// - Returns: a range or nil
    private func rangeToRemove(from action: VoiceAction) -> CountableClosedRange<Int>? {
        if action.removeUntil.count > 0 {
            logger.debug("remove \(action)")
            for actionType in action.removeUntil {
                // in the case actionType is an AddClientVoiceAction, remove all and restart.
                if actionType == VoiceAction.self {
                    return 0...actions.count-2
                }
                // check for the types and look up the range
                if let start = actions.reversed().first(where: {actionType == type(of: $0) && $0 !== action}),
                    let index = actions.index(of: start) {
                    return index+1...actions.count-2
                }
            }
        }
        return nil
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
