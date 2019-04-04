//
//  Item+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio

protocol Createable {
    associatedtype CreatedType: NSManagedObject
    static func create(in context: NSManagedObjectContext) -> CreatedType
}

extension Item: Fetchable, Createable {
    
    public typealias CreatedType = Item
    public typealias FetchableType = Item
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    static func create(in context: NSManagedObjectContext) -> Item {
        let item = Item(inContext: context)
        item.uuid = UUID().uuidString.lowercased()
        item.number = item.uuid?.shortenedUUIDString
        item.createdTimestamp = Date()
        item.updatedTimestamp = Date()
        item.localUpdateTimestamp = Date()
        item.price = NSDecimalNumber.zero
        return item
    }
}
