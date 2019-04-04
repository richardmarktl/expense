//
//  TotalModel.swift
//  InVoice
//
//  Created by Georg Kitz on 15/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import SwiftMoment
import RxSwift

struct TotalItem {
    let total: String
    let totalMessage: String
}

class TotalModel {
    
    private let totalSubject: Variable<TotalItem> = Variable(TotalItem(total: "", totalMessage: ""))
    private let bag = DisposeBag()
    
    var totalObservable: Observable<TotalItem> {
        return totalSubject.asObservable()
    }
    
    var total: TotalItem {
        return totalSubject.value
    }
    
    init(with context: NSManagedObjectContext) {

        let paid = NSPredicate.paidInvoices()
        
        let start = moment().startOf(TimeUnit.Years).date as CVarArg
        let timeframe = NSPredicate(format: "paidTimestamp => %@", start)
        
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [paid, timeframe])
        Invoice.rxAllObjects(matchingPredicate: predicate, context: context).observeOn(background).map { (paid) -> NSDecimalNumber in
            return paid.reduce(NSDecimalNumber.zero, { (current, invoice) -> NSDecimalNumber in
                return current + (invoice.total ?? NSDecimalNumber.zero)
            })
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] total in
            
            let year = moment().format("YYYY")
            self?.totalSubject.value = TotalItem(total: total.asCurrency(currencyCode: nil), totalMessage: R.string.localizable.totalPaidThisYear(year))
            
        }).disposed(by: bag)
    }
}
