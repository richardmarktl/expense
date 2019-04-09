//
//  Entry+Fetchable.swift
//  expense
//
//  Created by Richard Marktl on 09.04.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio

enum EntryType: Int32 {
    case expense = 0
    case revenue = 1
}

extension Entry: Fetchable, Createable {
    public typealias CreatedType = Entry
    public typealias FetchableType = Entry
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func create(in context: NSManagedObjectContext) -> Entry {
        let instance = Entry(inContext: context)
        instance.uuid = UUID().uuidString.lowercased()
        instance.createdTimestamp = Date()
        instance.updatedTimestamp = Date()
        instance.localUpdateTimestamp = Date()
        instance.type = EntryType.expense.rawValue
        return instance
    }
    
    var entryType: EntryType {
        get {
            guard let entryType = EntryType(rawValue: type) else {
                return .expense
            }
            return entryType
        }
        set {
            type = newValue.rawValue
        }
    }
}
