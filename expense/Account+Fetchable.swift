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
import Horreum
import SwiftMoment

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
    
    static func create(in context: NSManagedObjectContext) -> Account {
        let item = Account(inContext: context)
        item.uuid = UUID().uuidString.lowercased()
        item.tax = NSDecimalNumber(value: 20)
        item.trailStartedTimestamp = Date()
        item.trailEndedTimestamp = moment().add(7, .Days).date
        item.createdTimestamp = Date()
        item.updatedTimestamp = Date()
        
        return item
    }
    
    static func current(context: NSManagedObjectContext = Horreum.instance!.mainContext) -> Account {
        return Account.allObjects(context: context).first!
    }
    
    var hasCountry: Bool {
        if let country = self.country {
            return country.count > 0
        }
        return false
    }
}
