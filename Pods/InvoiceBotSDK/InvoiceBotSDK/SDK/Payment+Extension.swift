//
//  Payment+Fetchabel.swift
//  InVoice
//
//  Created by Georg Kitz on 30/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreDataExtensio
import CoreData
import RxSwift

public enum PaymentType: String {
    case cash
    case check
    case bankTransfer
    case creditCard
    case payPal
    case online
    case other
    
    var asLocalizedString: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

extension Payment: Fetchable {
    
    public typealias FetchableType = Payment
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func rxPayments(for invoice: Invoice, in context: NSManagedObjectContext) -> Observable<[Payment]> {
        let predicate = NSPredicate(format: "invoice = %@", invoice)
        return Payment.rxMonitorChanges(context).startWith((inserted: [], updated: [], deleted: [])).map({ _ in
            return Payment.allObjects(matchingPredicate: predicate, context: context)
        })
    }
    
    public var paymentType: PaymentType {
        get {
            guard let typeString = type, let paymentType = PaymentType(rawValue: typeString) else {
                return .cash
            }
            return paymentType
        }
        set {
            type = newValue.rawValue
        }
    }
}
