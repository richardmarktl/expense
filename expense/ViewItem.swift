//
//  ViewItem.swift
//  Stargate
//
//  Created by Georg Kitz on 13/09/2017.
//  Copyright © 2017 DeliveryHero AG. All rights reserved.
//

import Foundation
import CoreData

class ViewItem<T> where T: NSManagedObject {
    
    let objectId: NSManagedObjectID
    let item: T
    
    func item(in context: NSManagedObjectContext) -> T {
        return loadItem(with: objectId, in: context)
    }
    
    init(item: T) {
        self.item = item
        self.objectId = item.objectID
    }
    
    convenience init(objectId: NSManagedObjectID, context: NSManagedObjectContext) {
        let loadedItem = loadItem(with: objectId, in: context) as T
        self.init(item: loadedItem)
    }
}

private func loadItem<T: NSManagedObject>(with objectId: NSManagedObjectID, in context: NSManagedObjectContext) -> T {
    guard let loadedItem = context.object(with: objectId) as? T else {
        fatalError()
    }
    return loadedItem
}
