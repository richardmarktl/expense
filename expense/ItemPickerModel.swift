//
//  ItemPickerModel.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData
import CoreDataExtensio
import ContactsUI
import Horreum

class ItemPickerModel: Model {
    
    let job: Job
    
    init(searchObservable: Observable<String>, for job: Job, context: NSManagedObjectContext) {
        
        self.job = job
        
        super.init(with: context)
        
        let itemObs = Item.rxAllObjects(matchingPredicate: NSPredicate.undeletedItem(), sorted: [NSSortDescriptor(key: "title", ascending: true)], context: context).take(1).map { (items) in
            return items.map { ItemItem(item: $0) }
        }
        
        Observable.combineLatest(itemObs, searchObservable) { (obs, obs2) in
            return (obs, obs2)
            }.map { (items, searchString) -> [ItemItem] in
                
                if searchString.count == 0 {
                    return items
                }
                
                return items.filter({ (item) -> Bool in
                    return item.title.lowercased().contains(searchString)
                })
                
            }.map { (items) in
                
                let rowsSection1: [ConfigurableRow] = [
                    TableRow<AddCell, NewOrderAction>(item: AddItem(title: R.string.localizable.createNewItem()), action: NewOrderAction())
                ]
                
                let rowsSection2: [ConfigurableRow] = items.map({ (item) -> ConfigurableRow in
                    let configRow: ConfigurableRow = TableRow<ItemCell, PickItemAction>(item: item, action: PickItemAction())
                    return configRow
                })
                
                return [
                    Section(rows: rowsSection1, headerTitle: R.string.localizable.actions()),
                    Section(rows: rowsSection2, headerTitle: R.string.localizable.items())
                ]
                
            }.bind(to: sectionsVariable).disposed(by: bag)
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
}
