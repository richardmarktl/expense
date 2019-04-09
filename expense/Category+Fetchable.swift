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

extension Category: Fetchable, Createable {
    public typealias CreatedType = Category
    public typealias FetchableType = Category
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func create(in context: NSManagedObjectContext) -> Category {
        let instance = Category(inContext: context)
        instance.uuid = UUID().uuidString.lowercased()
        instance.createdTimestamp = Date()
        instance.updatedTimestamp = Date()
        instance.localUpdateTimestamp = Date()
        return instance
    }
}
