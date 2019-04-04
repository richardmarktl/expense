//
//  CheckGeneratorLimit.swift
//  InVoice
//
//  Created by Georg Kitz on 30/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import SwiftMoment
import Horreum
import CoreData
import Crashlytics

struct LimitChecker {
    
    enum LimitType {
        case invoice
        case offer
    }
    
    static let limit = 5
    
    static func isWithingLimits(for type: LimitType, isReceiptValid: Bool = StoreService.instance.hasValidReceipt, in context: NSManagedObjectContext = Horreum.instance!.mainContext) -> Bool {
        
        if isReceiptValid {
            return true
        }
        
        let beginOfMonth = moment().startOf(TimeUnit.Months).startOf(TimeUnit.Days).date
        let endOfMonth = moment().endOf(TimeUnit.Months).endOf(TimeUnit.Days).date
        let format = "remoteId != %d AND createdTimestamp >= %@ AND createdTimestamp <= %@"
        CLSLogv("RemoteId: %d, Begin: %@, End: %@", getVaList([DefaultData.TestRemoteID, beginOfMonth as CVarArg, endOfMonth as CVarArg]))
        let predicate = NSPredicate(format: format, DefaultData.TestRemoteID, beginOfMonth as CVarArg, endOfMonth as CVarArg)
        CLSLogv("Predicate: %@", getVaList([predicate]))
        
        if case .invoice = type {
            return Invoice.allObjectsCount(matchingPredicate: predicate, context: context) < LimitChecker.limit
        } else {
            return Offer.allObjectsCount(matchingPredicate: predicate, context: context) < LimitChecker.limit
        }
    }

    static func hasValidSubscription() -> Bool {
        return StoreService.instance.hasValidReceipt
    }
}
