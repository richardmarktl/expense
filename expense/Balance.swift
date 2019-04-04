//
//  BalanceModel.swift
//  InVoice
//
//  Created by Georg Kitz on 27/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreDataExtensio
import CoreData

struct Balance {
    let total: NSDecimalNumber
    let subtotal: String
    let discount: String
    let vat: String
    let vats: [Tax]
    let vatToTotalItems: [String]
    let paid: String
    let balance: String
    let balanceValue: NSDecimalNumber
}

struct BalanceModel {
    static func balanceObservable(for job: Job, in context: NSManagedObjectContext) -> Observable<Balance> {
        
        let jobObs = job.rxChangesOnSelf(in: context)
        let orderObs = Order.rxOrders(for: job, in: context)
        
        var paymentObs: Observable<[Payment]> = Observable.just([])
        if let invoice = job as? Invoice {
            paymentObs = Payment.rxPayments(for: invoice, in: context)
        }
        
        return Observable.combineLatest(jobObs, orderObs, paymentObs) { (job, orders, payments) -> Balance in
            return balance(with: job, from: orders, payments: payments)
        }.startWith(balance(for: job))
    }
    
    static func balance(for job: Job) -> Balance {
        
        var payments: [Payment] = []
        if let invoice = job as? Invoice {
            payments = invoice.paymentsTyped
        }
        
        return balance(with: job, from: job.ordersTyped, payments: payments)
    }
    
    private static func balance(with job: Job, from orders: [Order], payments: [Payment]) -> Balance {
        let currencyCode = job.currency
        let paymentTotal = payments.reduce(NSDecimalNumber.zero, { (result, payment) -> NSDecimalNumber in
            return result + (payment.amount ?? NSDecimalNumber.zero)
        })
        
        let subtotalWithoutGlobalDiscount = orders.subtotal()
        var subtotalWithGlobalDiscount = subtotalWithoutGlobalDiscount
        
        var discount = job.discount ?? NSDecimalNumber.zero
        var discountValue = NSDecimalNumber.zero
        let isDiscountAbsolute = job.isDiscountAbsolute
        if discount != NSDecimalNumber.zero && subtotalWithoutGlobalDiscount != NSDecimalNumber.zero {
            if isDiscountAbsolute {
                discount = discount / subtotalWithoutGlobalDiscount * 100.0
            }
            discountValue = subtotalWithoutGlobalDiscount * discount / 100
            subtotalWithGlobalDiscount = orders.subtotal(with: discount)
        }
        
        let vats = orders.vats(with: discount)
        let totalTax = vats.tax
        
        let vatToTotalItems = vats.vatToTotal.map({ (value) -> String in
            return R.string.localizable.vatPercentOf(value.key, value.value.asCurrency(currencyCode: currencyCode))
        })
        
        let total = subtotalWithGlobalDiscount + totalTax
        let balance = total - paymentTotal
        
        return Balance(total: total.asRounded(), subtotal: subtotalWithoutGlobalDiscount.asCurrency(currencyCode: currencyCode), discount: discountValue.asCurrency(currencyCode: currencyCode), vat: totalTax.asCurrency(currencyCode: currencyCode), vats: vats,
                       vatToTotalItems: vatToTotalItems, paid: paymentTotal.asCurrency(currencyCode: currencyCode), balance: balance.asCurrency(currencyCode: currencyCode), balanceValue: balance.asRounded())
    }
}
