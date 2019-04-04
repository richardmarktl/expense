//
//  JobStateChecker.swift
//  InVoice
//
//  Created by Georg Kitz on 22/02/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

struct JobStateChecker {
    
    static func checkJobStates(in context: NSManagedObjectContext) -> Observable<Void> {
        return NotificationCenter.default.rx.notification(Notification.Name.UIApplicationDidBecomeActive).flatMap { (_) -> Observable<Void> in
            let predicate = NSPredicate(
                format: "remoteId > 0 AND (state == %d OR state == %d OR state == %d OR state == %d)",
                JobState.sent.rawValue as CVarArg,
                JobState.opened.rawValue as CVarArg,
                JobState.paid.rawValue as CVarArg,
                JobState.signed.rawValue as CVarArg
            )
            .and(NSPredicate.undeletedItem())
            
            let invoices = Invoice.allObjects(matchingPredicate: predicate, context: context)
            let offers = Offer.allObjects(matchingPredicate: predicate, context: context)
            
            var obs = Observable.just(())
            
            invoices.forEach({ (invoice) in
                obs = obs.concat(InvoiceRequest.load(with: invoice.remoteId, context: context).mapToVoid())
            })
            
            offers.forEach({ (offer) in
                obs = obs.concat(OfferRequest.load(with: offer.remoteId, context: context).mapToVoid())
            })
            
            return obs
                .concat(loadPaymentsForAllPaidInvoicesWithoutAPayment(in: context))
                .takeLast(1)
        }
    }
    
    static func loadPaymentsForAllPaidInvoicesWithoutAPayment(in context: NSManagedObjectContext) -> Observable<Void> {
        let predicate = NSPredicate(format: "remoteId > 0 AND state == %d AND payments.@count == 0", JobState.paid.rawValue as CVarArg).and(NSPredicate.undeletedItem())
        let invoices = Invoice.allObjects(matchingPredicate: predicate, context: context)
        var obs = Observable.just(())
        invoices.forEach { (invoice) in
            obs = obs.concat(PaymentRequest.load(for: invoice.remoteId, updatedAfter: nil, updateIn: context).takeLast(1).mapToVoid())
        }
        return obs.takeLast(1)
    }
}
