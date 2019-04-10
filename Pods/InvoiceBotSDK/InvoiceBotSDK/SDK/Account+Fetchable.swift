//
//  Defaults+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio

extension Account: Fetchable, Createable {
    public typealias CreatedType = Account
    public typealias FetchableType = Account
    public typealias I = NSDecimalNumber
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func create(in context: NSManagedObjectContext) -> Account {
        let item = Account(inContext: context)
        item.uuid = UUID().uuidString.lowercased()
        item.tax = NSDecimalNumber(value: 20)
    
        let trailStartedTimestamp = Date()
        item.trailStartedTimestamp = trailStartedTimestamp
        item.trailEndedTimestamp = Calendar.current.date(byAdding: .day, value: 7, to: trailStartedTimestamp)
        
        item.createdTimestamp = Date()
        item.updatedTimestamp = Date()
        
        return item
    }
    
    public static func current(context: NSManagedObjectContext = CoreDataContainer.instance!.mainContext) -> Account {
        return Account.allObjects(context: context).first!
    }
    
    public var hasCountry: Bool {
        if let country = self.country {
            return country.count > 0
        }
        return false
    }
}
