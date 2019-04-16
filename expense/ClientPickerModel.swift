//
//  ClientPickerModel.swift
//  InVoice
//
//  Created by Georg Kitz on 16/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData
import CoreDataExtensio
import ContactsUI
import Horreum

class ClientPickerModel: Model {
    
    init(searchObservable: Observable<String>, context: NSManagedObjectContext) {
        
        super.init(with: context)
        
        let predicate = NSPredicate.activeClients().and(.undeletedItem())
        let clientObs = Client.rxAllObjects(matchingPredicate: predicate, context: context).take(1).map { (clients) in
            return clients.map { ClientItem(defaultData: $0) }
        }
        
        Observable.combineLatest(clientObs, searchObservable) { (obs, obs2) in
            return (obs, obs2)
        }.map { (clients, searchInput) -> [ClientItem] in
        
            let searchString = searchInput.asSearchString
            if searchString.count == 0 {
                return clients
            }
            
            return clients.filter({ (client) -> Bool in
                return client.clientName.lowercased().contains(searchString) || client.clientInfo.lowercased().contains(searchString)
            })
            
        }.map { (clients) in
         
            let rowsSection1: [ConfigurableRow] = [
                TableRow<AddCell, NewClientAction>(
                    item: AddItem(title: R.string.localizable.createNewClient(), image: R.image.add_client()),
                    action: NewClientAction()
                ),
                TableRow<AddCell, PickFromAddressBookAction>(
                    item: AddItem(title: R.string.localizable.pickFromAddressbook(), image: R.image.add_import_from_address_book()),
                    action: PickFromAddressBookAction(with: context)
                )
            ]
            
            let rowsSection2: [ConfigurableRow] = clients.map({ (client) -> ConfigurableRow in
                let configRow: ConfigurableRow = TableRow<ClientCell, PickClientAction>(item: client, action: PickClientAction())
                return configRow
            })
            
            return [
                Section(rows: rowsSection1, headerTitle: R.string.localizable.actions()),
                Section(rows: rowsSection2, headerTitle: R.string.localizable.clients())
            ]
            
        }.bind(to: sectionsVariable).disposed(by: bag)
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
}
