//
//  Invoice+Predicate.swift
//  InVoice
//
//  Created by Georg Kitz on 15/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

extension NSPredicate {
    
    class func openInvoices() -> NSPredicate {
        return NSPredicate(format: "paidTimestamp == NULL").and(undeletedItem())
    }
    
    class func unpaidInvoices() -> NSPredicate {
        return NSPredicate(format: "paidTimestamp == NULL").and(undeletedItem())
    }
    
//    class func overdueInvoices() -> NSPredicate {
//        let endOfDay = Date().endOfDay
//        let dueDatePredicate = NSPredicate(format: "dueTimestamp < %@", endOfDay as NSDate)
//        return NSPredicate(format: "paidTimestamp == NULL").and(dueDatePredicate).and(undeletedItem())
//    }
//
//    class func overdueTomorrowInvoices() -> NSPredicate {
//        let tomorrow = Date().tomorrow
//        let startOfDay = tomorrow.startOfDay
//        let endOfDay = tomorrow.endOfDay
//        let dueDatePredicate = NSPredicate(format: "dueTimestamp < %@ AND dueTimestamp > %@", endOfDay as NSDate, startOfDay as NSDate)
//        return NSPredicate(format: "paidTimestamp == NULL").and(dueDatePredicate).and(undeletedItem())
//    }
//
//    class func unsentInvoices() -> NSPredicate {
//        return NSPredicate(format: "state == %d", JobState.notSend.rawValue).and(undeletedItem())
//    }
//
//    class func unopenedInvoices() -> NSPredicate {
//        return NSPredicate(format: "state >= %d AND state < %d AND paidTimestamp == NULL", JobState.sent.rawValue, JobState.downloaded.rawValue).and(undeletedItem())
//    }
    
    class func paidInvoices() -> NSPredicate {
        return NSPredicate(format: "paidTimestamp != NULL").and(undeletedItem())
    }
    
    class func undeletedItem() -> NSPredicate {
        return NSPredicate(format: "deletedTimestamp == NULL")
    }
    
//    class func noTestData() -> NSPredicate {
//        return NSPredicate(format: "remoteId != %d", DefaultData.TestRemoteID)
//    }
//
    class func activeClients() -> NSPredicate {
        return NSPredicate(format: "isActive = YES")
    }
    
    func and(_ predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [self, predicate])
    }
    
    func or(_ predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [self, predicate])
    }
}
