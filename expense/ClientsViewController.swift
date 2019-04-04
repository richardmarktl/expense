//
//  ClientsViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 15/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData
import Horreum
import ContactsUI

class ClientsViewController: SearchableTableModelController<ClientOverviewItem, ClientsModel> {
    
    @IBOutlet weak var addButton: HoverButton!
    @IBOutlet weak var addContactButton: HoverButton!
    private let emptyViewAddSubject: PublishSubject<Void> = PublishSubject()
    
    func addContact() {
        let contactController = CNContactPickerViewController()
        let cancel = contactController.rx.didCancel
        
        _ = contactController.rx.didSelect.take(1).takeUntil(cancel).subscribe(onNext: { [unowned self] (contact) in
            // store the action as closure and run it after the contact picker view was dismissed.
            // the contact ui causes problems if we show it during the dismiss animation, so we
            // wait until viewDidAppear and
            _ = self.rx.viewDidAppear.take(1).subscribe(onNext: { (_) in
                let context = Horreum.instance!.childContext()
                let client = Client.fromCNContact(contact: contact, in: context)
                let nCtr = ClientViewController.show(item: client, in: context)
                Analytics.clientFromContact.logEvent()
                self.present(nCtr, animated: true)
            })
        })
        present(contactController, animated: true)
    }
    
    override func viewDidLoad() {
        
        emptyTitle = R.string.localizable.noClientTitle()
        emptyMessage = R.string.localizable.noClientMessage()
        emptyViewInsertBelowView = addContactButton
        
        addContactButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            if !CurrentAccountState.isProExpired {
                self.addContact()
            } else {
                UpsellTrialExpiredController.present(in: self)
            }
        }).disposed(by: bag)
        
        addButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            if !CurrentAccountState.isProExpired {
                let nCtr = ClientViewController.createItem()
                Analytics.clientNew.logEvent()
                self.present(nCtr, animated: true)
            } else {
                UpsellTrialExpiredController.present(in: self)
            }
        }).disposed(by: bag)
        
        context = Horreum.instance!.mainContext
        model = ClientsModel(searchObservable: searchObservable, with: context)
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        title = R.string.localizable.clients()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.client.logEvent()
    }
}
