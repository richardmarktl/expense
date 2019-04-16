//
//  PaymentModel.swift
//  InVoice
//
//  Created by Georg Kitz on 01/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

/// Client Model
class PaymentModel: Model {
    
    /// Data model items that hold the values the user edits
    private let amount: NumberEntry
    private let method: PaymentTypeEntry
    private let date: DateItem
    private let note: TextEntry
    
    /// we created the data from one of those items
    let payment: Payment?
    let invoice: Invoice!
    
    let title: String
    let isDeleteButtonHidden: Bool
    let deleteButtonTitle: String
    
    /// Observable that determines when to enable the save button, basically we just need a `description` to store an item
    var saveEnabledObservable: Observable<Bool> {
        return amount.data.asObservable().map({ (value) -> Bool in
            return value != NSDecimalNumber.zero
        })
    }
    
    /// Inits the model
    ///
    /// - Parameters:
    ///   - item: if we get a template item we init it with the data of the template
    ///   - order: if we get an order we can modify it or delete it
    ///   - context: the context we operate on
    init(payment: Payment?, for invoice: Invoice, in context: NSManagedObjectContext) {
        
        self.payment = payment
        self.invoice = invoice
        
        deleteButtonTitle = R.string.localizable.remove()
        isDeleteButtonHidden = payment == nil
        
        title = payment == nil ? R.string.localizable.newItem() : R.string.localizable.updateItem()
        
        amount = NumberEntry(payment: payment)
        method = PaymentTypeEntry(payment: payment)
        date = DateItem(payment: payment)
        note = TextEntry(payment: payment)
        
        let rows: [ConfigurableRow] = [
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: amount, action: FirstResponderActionNumberCell()),
            TableRow<DateCell, DateAction>(item: date, action: DateAction()),
            TableRow<PaymentTypeCell, PaymentTypeAction>(item: method, action: PaymentTypeAction()),
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: note, action: FirstResponderActionTextViewCell())
        ]
        
        super.init(with: context)
        
        sections = [Section(rows: rows)]
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
    
    /// Saves the current data an returns a new order
    ///
    /// - Returns: the created or modified order
    func save() -> Payment {
        
        let newPayment: Payment
        if let payment = payment {
            newPayment = payment
        } else {
            newPayment = Payment(inContext: context)
            newPayment.uuid = UUID().uuidString.lowercased()
            newPayment.createdTimestamp = Date()
            newPayment.updatedTimestamp = Date()
            newPayment.invoice = invoice
        }
        
        newPayment.localUpdateTimestamp = Date()
        newPayment.amount = amount.value
        newPayment.paymentDate = date.value
        newPayment.paymentType = method.data.value
        newPayment.note = note.value.value
        
        return newPayment
    }
    
    /// Deletes the order
    func delete() {
        guard let payment = payment else {
            return
        }
        payment.deletedTimestamp = Date()
        payment.invoice = nil
    }
}
