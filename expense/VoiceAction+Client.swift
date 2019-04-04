//
//  Action+Client.swift
//  InVoice
//
//  Created by Richard Marktl on 20.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import Horreum

/// This is the first action to handle "add the client".
/// This action has 3 child actions.
/// - ClientNotFoundAction
/// - ClientFoundVoiceAction
/// - MultipleClientFoundAction
class AddClientVoiceAction: VoiceAction {
    init(parent action: VoiceAction?, config cfg: VoiceActionConfig) {
        var output = R.string.localizable.addClientAction()
        if cfg.result == .offer {
            output = R.string.localizable.addClientOfferAction()
        }
        super.init(parent: action,
                   voiceOutput: output,
                   visualOutput: R.reuseIdentifier.questionViewCell.identifier,
                   config: cfg)
        isRepeatable = true
        if action != nil {
            removeUntil.append(VoiceAction.self)
        }
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        if input.isEmpty {
            return ClientNotFoundVoiceAction(parent: self, name: input)
        }
        // so a empty input should be catched by the voice input controller
        
        // look for the clients in the database
        let clients = searchFor(clientName: input)
        
        if clients.count == 0 {
            return ClientNotFoundVoiceAction(parent: self, name: input)
        }
        if clients.count == 1 {
            return ClientFoundVoiceAction(parent: self, client: clients[0])
        }
        return MultipleClientFoundVoiceAction(parent: self, clients: clients)
    }
    
    private func searchFor(clientName: String) -> [Client] {
        let predicate = NSPredicate(format: "name contains [cd] %@", clientName).and(NSPredicate.activeClients().and(.undeletedItem()))
        return Client.allObjects(matchingPredicate: predicate, context: config.childContext)
    }
}

/// This class is used to collect the voice input the child is definied by its parent.
class InputVoiceAction: VoiceAction {
    convenience init(parent: VoiceAction) {
        self.init(parent: parent, visualOutput: R.reuseIdentifier.answerViewCell.identifier, config: parent.config)
        self.needsVoiceInput = false
    }
}

/// This class handles the found client
/// This action has 1 child action.
/// - AddItemVoiceAction
class ClientFoundVoiceAction: VoiceAction {
    let client: Client
    
    /// The nextRepeatableParent chain is broken by the ClientFoundVoiceAction, because we don't allow to change client.
    override var repeatableParent: VoiceAction? {
        return nil
    }
    
    init(parent action: VoiceAction, client: Client) {
        self.client = client
        
        super.init(parent: action,
                   voiceOutput: R.string.localizable.clientFoundAction(client.name!),
                   visualOutput: R.reuseIdentifier.clientViewCell.identifier,
                   config: action.config)
        
        needsVoiceInput = false
        removeUntil.append(AddClientVoiceAction.self)
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        return AddItemVoiceAction(parent: self)
    }
}

/// This class handles the not found client, it will try to create a client it will take as input an address string.
/// This action has 1 child action.
/// - NewEmailOrNumberVoiceAction
class ClientNotFoundVoiceAction: VoiceAction {
    var client: Client
    init(parent action: VoiceAction, name: String) {
        
        client = Client(inContext: action.config.childContext)
        client.name = name
        super.init(parent: action,
                   voiceOutput: R.string.localizable.notFoundAction(),
                   visualOutput: R.reuseIdentifier.questionViewCell.identifier,
                   config: action.config)
        duration = .long
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        client.address = input
        return NewEmailOrNumberVoiceAction(parent: self, client: client)
    }
    
    override func prepareDeletion() {
        config.childContext.delete(client)
    }
}

/// This class is the second part of the new client actions.
/// This action has 1 child action.
/// - NewClientVoiceAction
class NewEmailOrNumberVoiceAction: VoiceAction {
    var client: Client
    init(parent action: VoiceAction, client: Client) {
        self.client = client
        super.init(parent: action,
                  voiceOutput: R.string.localizable.newContactDataAction(),
                  visualOutput: R.reuseIdentifier.questionViewCell.identifier,
                  config: action.config)
        duration = .medium
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        if !input.isEmpty && input.rangeOfCharacter(from: numberCharacters) != nil {
            client.email = input
        } else {
            client.phone = input
        }
    
        return NewClientVoiceAction(parent: self, client: client)
    }
}

/// This class is the third part of the new client actions. It will create a new client if the user agrees.
/// This action has 2 child action.
/// - ClientFoundVoiceAction
/// - AddClientVoiceAction (restarted)
class NewClientVoiceAction: VoiceAction {
    var client: Client?
    
    override lazy var controller: UIViewController? = {
        
        guard let client = client else {
            return nil
        }
        
        let completionBlock = { [unowned self] (client: Client) in
            self.client = client
            self.touchInputSubject?.onNext(())
        }
        
        let cancelBlock = {
            self.config.childContext.delete(self.client!)
            self.client = nil
            self.touchInputSubject?.onNext(())
        }
        
        return ClientViewController.show(item: client, in: client.managedObjectContext!, completionBlock: completionBlock, cancelBlock: cancelBlock)
    }()
    
    init(parent action: VoiceAction, client: Client) {
        self.client = client
        super.init(parent: action, visualOutput: R.reuseIdentifier.answerViewCell.identifier, config: action.config)
        touchInputSubject = PublishSubject<Void>()
        needsVoiceInput = false
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        if let client = client {
            return ClientFoundVoiceAction(parent: self, client: client)
        }
        return AddClientVoiceAction(parent: self, config: config)
    }
}

/// This class handles the part if there are is more than 1 client.
/// This action has 1 child action.
/// - MultipleClientSelectionAction
class MultipleClientFoundVoiceAction: VoiceAction {
    var clients: [Client]
    init(parent action: VoiceAction, clients: [Client]) {
        self.clients = clients
        super.init(parent: action,
                  voiceOutput: R.string.localizable.multipleFoundAction(),
                  visualOutput: R.reuseIdentifier.questionViewCell.identifier,
                  config: action.config)
        needsVoiceInput = false
        
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        return MultipleClientSelectionVoiceAction(parent: self, clients: clients)
    }
}

/// This class handles the part the selection client part.
/// This action has 1 child action.
/// - ClientFoundVoiceAction
class MultipleClientSelectionVoiceAction: VoiceAction {
    var clients: [Client]
    var client: Client

    init(parent action: VoiceAction, clients: [Client]) {
        self.clients = clients
        self.client = clients[0]
        super.init(parent: action,
                   visualOutput: R.reuseIdentifier.multipleSelectionViewCell.identifier,
                   config: action.config)
        touchInputSubject = PublishSubject<Void>()
        needsVoiceInput = false
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        return ClientFoundVoiceAction(parent: self, client: self.client)
    }
}
