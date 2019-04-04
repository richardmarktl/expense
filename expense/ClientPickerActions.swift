//
//  ClientPickerActions.swift
//  InVoice
//
//  Created by Georg Kitz on 17/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import ContactsUI

// MARK: - Parent Action
class ClientSelectAction {
    
    /// completes picking client, calls completion handler and dismisses the controller
    ///
    /// - Parameters:
    ///   - client: the client we picked
    ///   - controller: the controller we want to use to call the completion handler on
    func complete(with client: Client, in controller: UIViewController) {
        guard let pickerController = controller as? ClientPickerViewController, let completion = pickerController.completionBlock else {
            return
        }
        
        completion(client)
        
        DispatchQueue.main.async {
            pickerController.parent?.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - NewClientAction
class NewClientAction: ClientSelectAction, TapActionable {
    typealias RowActionType = AddItem
    
    func performTap(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        guard let nCtr = R.storyboard.clients.clientViewRootController(), let root = nCtr.childViewControllers.first as? ClientViewController else {
            return
        }
        
        root.item = Client.create(in: model.context)
        root.context = model.context
        root.completionBlock = { [unowned self] client in
            self.complete(with: client, in: ctr)
        }
        
        root.dismissActionBlock = { root in
            ctr.presentingViewController?.dismiss(animated: true)
        }
        
        root.cancelBlock = { [unowned root] in
            root.context.delete(root.item)
        }
        
        Analytics.addInvoiceNewClient.logEvent()
        ctr.present(nCtr, animated: true)
    }
    
    func rewindAction(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
    }
}

// MARK: - Picks client from the address book and copies it to the local storage
class PickFromAddressBookAction: ClientSelectAction, TapActionable {
    typealias RowActionType = AddItem
    private let context: NSManagedObjectContext
    
    init(with context: NSManagedObjectContext) {
        self.context = context
    }
    
    func performTap(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        let contactController = CNContactPickerViewController()
        let cancel = contactController.rx.didCancel
        
        _ = contactController.rx.didSelect.take(1).takeUntil(cancel).subscribe(onNext: { [unowned self] (contact) in
            
            let client = Client.fromCNContact(contact: contact, in: self.context)
            
            self.complete(with: client, in: ctr)
        })
        
        ctr.present(contactController, animated: true)
    }
    
    func rewindAction(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
    }
}

// MARK: - Picks one of the clients from the local storage
class PickClientAction: ClientSelectAction, TapActionable {
    typealias RowActionType = ClientItem
    func performTap(with rowItem: ClientItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        Analytics.addInvoicePickClient.logEvent()
        complete(with: rowItem.value, in: ctr)
    }
    
    func rewindAction(with rowItem: ClientItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}
