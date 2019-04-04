//
//  Action.swift
//  InVoice
//
//  Created by Richard Marktl on 20.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import RxSwift

/// The VoiceActionConfig carries objects needed in all VoiceAction items
struct VoiceActionConfig {
    var childContext: NSManagedObjectContext
    var result: InvoiceBotResult
}

/// The ProcessProtocol enforces that every Action class implements the process function.
protocol ProcessProtocol {
    func process(voiceInput input: String) -> VoiceAction
}

/// The class Action is used as base class in the Invoice Voice Bot implementation. Every action is either a voice
/// input or an choice view.
///
class VoiceAction: ProcessProtocol, Equatable {
    let visualOutput: String
    let voiceOutput: String
    let config: VoiceActionConfig
    let parent: VoiceAction?
    
    var isRepeatable: Bool
    var duration: SilenceDuration = .short
    var voiceInput: String?
    
    /// If this var is set, the view should remove all actions until it finds following action type
    internal(set) var removeUntil: [VoiceAction.Type] = []
    
    /// If this var is not set, the action visual output will be shown and after that the next action will be called
    internal(set) var needsVoiceInput: Bool = true
    
    /// This member will be set through processInput,
    private weak var child: VoiceAction?
    
    /// If this var is set a controller is shown instead of an visual output field
    internal(set) var controller: UIViewController?
    
    // if this var is set, the action awaits a visual user input.
    internal(set) var touchInputSubject: PublishSubject<Void>?

    /// An overriding class should use this field to break the chain, if a certain chain of voice actions should not
    /// be changeable. This property should always return the nearest repeatable parent action.
    public var repeatableParent: VoiceAction? {
        if isRepeatable {
            return self
        }
        
        return parent?.repeatableParent
    }
    
    public var hasRepeatableParent: Bool {
        if let parent = repeatableParent {
            return parent != self
        }
        return false
    }
    
    init(parent action: VoiceAction?, voiceOutput string: String = "", visualOutput view: String = "", config cfg: VoiceActionConfig) {
        parent = action
        voiceOutput = string
        visualOutput = view
        config = cfg
        isRepeatable = false
    }
    
    /// This method is used to encapsulate the input process. The voiceInput member is collected through the action
    /// itself and after it is collect it will processed.
    ///
    /// - Returns: The next Action.
    func processInput() -> VoiceAction {
        if let child = self.child {
            return child
        }
        
        let child = process(voiceInput: voiceInput ?? "")
        self.child = child
        return child
    }
    
    /// This method is used as override point to return the next action depending on the given input.
    ///
    /// - Parameter input: a input string used to determine the next action
    /// - Returns: the next action
    func process(voiceInput input: String) -> VoiceAction {
        return self
    }
    
    /// This method sets the input back to replay it.
    func replay() {
        self.child = nil
    }
    
    /// This method is used as override point to prepare the item for deletion.
    func prepareDeletion() {
    }
    
    static func == (lhs: VoiceAction, rhs: VoiceAction) -> Bool {
        return lhs === rhs
    }
}

/// This class is used for classic yes no questions
class DecisionVoiceAction: VoiceAction {
    var touched: Bool = false
    var confirmed: Bool = false
    
    init(parent action: VoiceAction) {
        super.init(parent: action, visualOutput: R.reuseIdentifier.decisionViewCell.identifier, config: action.config)
        touchInputSubject = PublishSubject<Void>()
    }
    
    internal func confirmed(voice input: String) -> Bool {
        if touched {
            return confirmed
        }
        return input.lowercased() == R.string.localizable.yes().lowercased()
    }
}

/// In the case an error occured this action will be created and displayed. After an error occurred stop the invoice bot
/// because wie have no recovery mode.
class ErrorVoiceAction: VoiceAction {
    override var repeatableParent: VoiceAction? {
        return nil
    }
    
    init(parent action: VoiceAction, message: String) {
        super.init(parent: action, visualOutput: R.reuseIdentifier.errorViewCell.identifier, config: action.config)
        needsVoiceInput = false
        voiceInput = message
    }
}
