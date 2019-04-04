//
//  MigrationItemAndOrderTitle.swift
//  InVoice
//
//  Created by Georg Kitz on 21.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData

struct MigrationItemAndOrderTitle {
    static func migrate(in context: NSManagedObjectContext) {
        
        let predicate = NSPredicate(format: "title = NULL OR title = ''")
        let items = Item.allObjects(matchingPredicate: predicate, context: context)
        let orders = Order.allObjects(matchingPredicate: predicate, context: context)
        
        items.forEach { (item) in
            item.title = item.itemDescription
        }
        
        orders.forEach { (order) in
            order.title = order.itemDescription
        }
        
        try? context.save()
    }
}
