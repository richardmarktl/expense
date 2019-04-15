//
//  PaymentModel.swift
//  InVoice
//
//  Created by Georg Kitz on 30/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import CoreDataExtensio
import ContactsUI
import Horreum

class PaymentItem: BasicItem<Payment> {
    let amount: String
    init(item: Payment) {
        
        amount = item.amount?.asCurrency(currencyCode: item.invoice?.currency) ?? ""
        
        let title = item.paymentDate!.asString(.medium, timeStyle: .none) + " " + item.paymentType.asLocalizedString
        super.init(title: title, defaultData: item)
    }
}

class PaymentsModel: Model {
    
    let invoice: Invoice
    
    var balanceObservable: Observable<Balance> {
        return BalanceModel.balanceObservable(for: invoice, in: context)
    }
    
    init(with invoice: Invoice, in context: NSManagedObjectContext) {
        
        self.invoice = invoice
        
        super.init(with: context)
        
        Payment.rxPayments(for: invoice, in: context).map { (payments) in
            return payments.map { PaymentItem(item: $0) }
        }.map { (payments) -> [TableSection] in
            
            let rowsSection1: [ConfigurableRow] = [
                TableRow<AddCell, MarkAsPayedInFullAction>(item: AddItem(title: R.string.localizable.markAsFullyPayed(), image: R.image.add_payment()), action: MarkAsPayedInFullAction()),
                TableRow<AddCell, NewPaymentAction>(item: AddItem(title: R.string.localizable.addPayment(), image: R.image.partial_payment_icon()), action: NewPaymentAction())
            ]
            
            let rowsSection2: [ConfigurableRow] = payments.map({ (payment) -> ConfigurableRow in
                let configRow: ConfigurableRow = TableRow<PaymentCell, ShowPaymentAction>(item: payment, action: ShowPaymentAction())
                return configRow
            })
            
            return [
                TableSection(rows: rowsSection1, headerTitle: R.string.localizable.actions()),
                TableSection(rows: rowsSection2, headerTitle: R.string.localizable.payments())
            ]
        }
        .bind(to: sectionsVariable).disposed(by: bag)
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
    
    func markAsPayedInFull() {
        
        let alreadyPaidAmount = invoice.paymentsTyped.reduce(NSDecimalNumber.zero) { (current, payment) -> NSDecimalNumber in
            return current + (payment.amount ?? NSDecimalNumber.zero)
        }
        
        let amountToPay = (invoice.total ?? NSDecimalNumber.zero) - alreadyPaidAmount
        if amountToPay <= NSDecimalNumber.zero {
            return
        }
        
        let newPayment = Payment(inContext: context)
        newPayment.uuid = UUID().uuidString.lowercased()
        newPayment.createdTimestamp = Date()
        newPayment.updatedTimestamp = Date()
        newPayment.localUpdateTimestamp = Date()
        newPayment.invoice = invoice
        newPayment.amount = amountToPay
        newPayment.paymentDate = Date()
        newPayment.paymentType = PaymentType.cash
        newPayment.note = ""
    }
}
