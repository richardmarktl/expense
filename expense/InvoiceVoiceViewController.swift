//
//  InvoiceStackedViewController.swift
//  InVoice
//
//  Created by Richard Marktl on 10.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class InvoiceVoiceViewController: UIViewController, AutoScroller {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var microphoneButton: MicrophoneButton!
    @IBOutlet weak var repeatButton: UIButton!
    
    // AutoScroller members
    weak var scrollView: UIScrollView!
    var scrollViewDefaultInsets: UIEdgeInsets = .zero
    var defaultInsets: UIEdgeInsets?
    var additionalHeight: CGFloat = 0
    
    public var source: JobsViewController?
    public var sourceType: InvoiceBotResult = .invoice
    
    private var tableFooterView: UIView?
    private let bag = DisposeBag()
    
    private var invoiceBot: InVoiceBot!
    
    private let startSubject: PublishSubject = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Autoscroller value
        scrollView = tableView
        invoiceBot = InVoiceBot(result: sourceType)
        title = sourceType == .invoice ? R.string.localizable.invoice() : R.string.localizable.offer()
        
        // save the table footer view for a later usage.
        tableFooterView = tableView.tableFooterView
        tableView.tableFooterView = nil
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: microphoneButton.frame.size.height, right: 0.0)
        repeatButton.alpha = 0.0
        repeatButton.isUserInteractionEnabled = false
        
        // The method askSpeechPermission will start the voice mode (only once) look at "viewDidAppear".
        startSubject.take(1).subscribe(onNext: { (_) in
            self.invoiceBot.askSpeechPermission()
        }).disposed(by: bag)

        invoiceBot.delegate = self
        invoiceBot.recording.subscribe(onNext: { (action: VoiceAction?, start: Bool) in
            if start {
                if let action = action {
                    self.microphoneButton.duration = action.duration
                }
                self.microphoneButton.record()
            } else {
                self.microphoneButton.stop()
            }
        }).disposed(by: bag)
        
        invoiceBot.voiceInput.subscribe(onNext: { (action: VoiceAction) in
            if let index = self.invoiceBot.actions.index(of: action),
                let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                if let cell = cell as? AnswerViewCell {
                    cell.textField.text = action.voiceInput
                }
            }
        }).disposed(by: bag)
        
        // if the microphone button is silent long enough stop listening
        microphoneButton.silenceObservable.subscribe(onNext: { [unowned self] (fired) in
            logger.debug("Invoice Bot was silent \(fired) input until now: \(String(describing: self.invoiceBot.action.voiceInput))")
            self.invoiceBot.tryToProcessInput()
        }).disposed(by: bag)
        
        microphoneButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            logger.debug("Invoice Bot tapObservable was tapped)")
            self.invoiceBot.tryToProcessInput()
        }).disposed(by: bag)
        
        repeatButton.rx.tap.subscribe(onNext: { [unowned self] (_) in
            logger.debug("pressed the repeat button")
            self.invoiceBot.replay()
        }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardEvents(rx.viewWillDisappear.mapToVoid())
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSubject.onNext(())
    }

    @IBAction func cancel(_ sender: AnyObject) {
        invoiceBot.cancel()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        let job = invoiceBot.save()
        if let source = source {
            source.job = job
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - The InvoiceBotDelegate implementation
extension InvoiceVoiceViewController: InvoiceBotDelegate {
    func bot(_ bot: InVoiceBot, show action: VoiceAction, removed range: CountableClosedRange<Int>?) {
        
        tableView.beginUpdates()
        if let range = range {
            tableView.deleteRows(at: buildIndexPaths(range: range), with: .top)
        }
        let indexPath = IndexPath(row: invoiceBot.actions.count-1, section: 0)
        
        tableView.insertRows(at: [indexPath], with: .top)
        tableView.endUpdates()
        
        // scroll to the new inserted action and do it after the element was added
        delayScrollTo(to: indexPath)
        
        // in the case a controller is present display it.
        if let controller = action.controller {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func bot(_ bot: InVoiceBot, removed range: CountableClosedRange<Int>?) {
        if let range = range {
            tableView.beginUpdates()
            tableView.deleteRows(at: buildIndexPaths(range: range), with: .top)
            tableView.endUpdates()
        }
    }
    
    func bot(_ bot: InVoiceBot, isActionRepeatable: Bool) {
        logger.debug("show the repeat button: \(isActionRepeatable)")
        UIView.animate(withDuration: 0.1) {
            self.repeatButton.alpha = isActionRepeatable ? 1.0 : 0.0
            self.repeatButton.isUserInteractionEnabled = isActionRepeatable
        }
    }
    
    func bot(_ bot: InVoiceBot, failed: Error) {
        let indexPath = IndexPath(row: invoiceBot.actions.count-1, section: 0)
        tableView.insertRows(at: [indexPath], with: .top)
        
        // scroll to the new inserted action and do it after the element was added
        delayScrollTo(to: indexPath)
    }
    
    private func delayScrollTo(to indexPath: IndexPath) {
        DispatchQueue.main.async {
            // guard the scroll against a cancelling action in the view.
            if self.tableView.numberOfRows(inSection: 0) > indexPath.row {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}

// MARK: - The TableView implementation
extension InvoiceVoiceViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoiceBot.actions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action: VoiceAction  = invoiceBot.actions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: action.visualOutput, for: indexPath)
        if var actionCell = cell as? ActionCellProtocol {
            actionCell.action = action
            if let answerCell = actionCell as? AnswerViewCell {
                answerCell.textField.rx.controlEvent(UIControlEvents.editingDidBegin).subscribe(onNext: { [unowned self](_) in
                    self.invoiceBot.startTextEditing()
                }).disposed(by: answerCell.reusableBag)
                
                answerCell.textField.rx.controlEvent(UIControlEvents.editingDidEnd).subscribe(onNext: { [unowned self](_) in
                    self.invoiceBot.stopTextEditing()
                }).disposed(by: answerCell.reusableBag)
            }
        }
        
        if let saveCell = cell as? SaveViewCell {
            saveCell.actionButton.tapObservable.subscribe(onNext: { [unowned self](_) in
                self.save(saveCell.actionButton)
            }).disposed(by: saveCell.reusableBag)
        }

        return cell
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if type(of: invoiceBot.action) != EndVoiceAction.self {
            return nil
        }
        
        let voiceAction = invoiceBot.actions[indexPath.row]
        if (type(of: voiceAction) == OrderVoiceAction.self) || (type(of: voiceAction) == ClientFoundVoiceAction.self) {
            return indexPath
        }
        return nil
        
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type(of: invoiceBot.action) != EndVoiceAction.self {
            return
        }
        
        let voiceAction = invoiceBot.actions[indexPath.row]
        if type(of: voiceAction) == OrderVoiceAction.self {
            guard let nCtr = R.storyboard.itemSearch.orderNavigationViewController(),
                  let root = nCtr.childViewControllers.first as? OrderViewController,
                  let action = voiceAction as? OrderVoiceAction else {
                return
            }
            
            root.item = action.order
            root.context = action.config.childContext
            root.completionBlock = { [unowned self] item in
                self.tableView.reloadData()
            }
            
            self.present(nCtr, animated: true, completion: nil)
        } else if type(of: voiceAction) == ClientFoundVoiceAction.self {
            guard let nCtr = R.storyboard.clients.clientViewRootController(),
                  let root = nCtr.childViewControllers.first as? ClientViewController,
                  let action = voiceAction as? ClientFoundVoiceAction else {
                return
            }

            root.item = action.client
            root.context = action.config.childContext
            root.completionBlock = { [unowned self] item in
                self.tableView.reloadData()
            }
            
            self.present(nCtr, animated: true, completion: nil)
        }
    }
    
    private func buildIndexPaths(range: CountableClosedRange<Int>) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for row in range {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        return indexPaths
    }
}
