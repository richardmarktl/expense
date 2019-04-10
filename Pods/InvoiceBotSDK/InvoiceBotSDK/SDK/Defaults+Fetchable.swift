//
//  Defaults+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 19.02.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import CoreDataExtensio

public struct DefaultParameters {
    let invoicePrefix: String
    let offerPrefix: String
}

extension Defaults: Fetchable {
    
    public typealias FetchableType = Defaults
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func create(in context: NSManagedObjectContext) -> Defaults {
        let design = Defaults(inContext: context)
        
        design.uuid = UUID().uuidString.lowercased()
        design.createdTimestamp = Date()
        design.updatedTimestamp = Date()
        design.localUpdateTimestamp = Date()
        
        return design
    }
    
    public static func currentInvoiceDefaults(in context: NSManagedObjectContext) -> Defaults {
        return Defaults.currentDefaults(for: .invoice, in: context)!
    }
    
    public static func currentOfferDefaults(in context: NSManagedObjectContext) -> Defaults {
        return Defaults.currentDefaults(for: .offer, in: context)!
    }
    
    public static func currentDefaults(for path: Path, in context: NSManagedObjectContext) -> Defaults? {
        let predicate = NSPredicate(format: "type = %@", path.rawValue)
        return Defaults.allObjects(matchingPredicate: predicate, fetchLimit: 1, context: context).first
    }
    
    public static func migrateFromAccountIfNeeded(account: Account, parameters: DefaultParameters, in context: NSManagedObjectContext) -> Observable<[Defaults]> {
        
        if account.remoteId == 0 {
            return Observable.empty()
        }
        
        let defaults = Defaults.allObjects(fetchLimit: 2, context: context)
        let wasUploaded = defaults.filter { $0.hasRemoteId }.count == 2
        if wasUploaded {
            return Observable.just(defaults)
        }
        
        let invoiceDefaults = Defaults.create(in: context)
        invoiceDefaults.type = Path.invoice.rawValue
        
        let offerDefaults = Defaults.create(in: context)
        offerDefaults.type = Path.offer.rawValue
        
        let o1 = DefaultsRequest.load(invoiceDefaults, updatedAfter: nil).do(onNext: { (defaults) in
            
            if defaults.prefix == nil {
                defaults.prefix = parameters.invoicePrefix
            } else if let prefix = defaults.prefix, prefix.count == 0 {
                defaults.prefix = parameters.invoicePrefix
            }
            
            try? defaults.managedObjectContext?.save()
        })
        
        let o2 = DefaultsRequest.load(offerDefaults, updatedAfter: nil).do(onNext: { (defaults) in
            
            if defaults.prefix == nil {
                defaults.prefix = parameters.offerPrefix
            } else if let prefix = defaults.prefix, prefix.count == 0 {
                defaults.prefix = parameters.offerPrefix
            }
            
            try? defaults.managedObjectContext?.save()
        })
        
        return Observable.combineLatest([o1, o2]) { (values) -> [Defaults] in
            return values
        }
    }
}
