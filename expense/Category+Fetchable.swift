//
//  Category+Fetchable.swift
//  expense
//
//  Created by Richard Marktl on 09.04.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio
import InvoiceBotSDK

extension BudgetCategory: Fetchable, Createable {
    public typealias CreatedType = BudgetCategory
    public typealias FetchableType = BudgetCategory
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func create(in context: NSManagedObjectContext) -> BudgetCategory {
        let instance = BudgetCategory(inContext: context)
        instance.uuid = UUID().uuidString.lowercased()
        instance.createdTimestamp = Date()
        instance.updatedTimestamp = Date()
        instance.localUpdateTimestamp = Date()
        return instance
    }
}
