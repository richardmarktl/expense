//
//  DetailModel.swift
//  InVoice
//
//  Created by Georg Kitz on 18/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import CoreDataExtensio

class DetailModel<ItemType: NSManagedObject & Createable>: TableModel<UITableView> {
    
    let item: ItemType
    var isDeleteButtonHidden: Bool
    let storeChangesAutomatically: Bool
    let deleteAutomatically: Bool
    
    var deleteButtonTitle: String?
    var title: String
    
    /// Observable that determines when to enable the save button, basically we just need a `description` to store an item
    var saveEnabledObservable: Observable<Bool> {
        fatalError()
    }
    
    var shouldAutoSelectFirstRowIfNewlyInserted: Bool {
        return true
    }

    var shouldShowCancelWarning: Bool {
        let all = context.updatedObjects
        return all.reduce(0, { (current, object) -> Int in
            //we don't want to show the dialog if the item was newly created
            let count = object.isInserted ? 0 : object.changedValues().count
            return current + count
        }) > 0
    }
    
    required init(item: ItemType, storeChangesAutomatically: Bool,
                  deleteAutomatically: Bool,
                  sections: [TableSection<UITableView>] = [], in context: NSManagedObjectContext) {

        self.item = item
        self.storeChangesAutomatically = storeChangesAutomatically
        self.deleteAutomatically = deleteAutomatically
        
        title = ""
        isDeleteButtonHidden = item.isInserted
        deleteButtonTitle = nil
        
        super.init(with: context)
        self.sections = sections
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
    
    /// Saves the current data an returns a item
    ///
    /// - Returns: the created or modified item
    @discardableResult func save() -> ItemType {
        
        if storeChangesAutomatically {
            try? context.save()
        }
        
        return item
    }
    
    /// Deletes the item
    func delete() {
        if deleteAutomatically {
            context.delete(item)
        }
        if storeChangesAutomatically {
            try? context.save()
        }
    }
}
