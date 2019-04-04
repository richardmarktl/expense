//
//  Invoice+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 13/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio
import SwiftMoment

extension Invoice: Fetchable {

    public typealias FetchableType = Invoice
    public typealias I = String
    
    var paymentsTyped: [Payment] {
        return payments?.allObjects as? [Payment] ?? []
    }

    public static func idName() -> String {
        return "uuid"
    }

    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    static func create(in context: NSManagedObjectContext) -> Invoice {
        let invoice = Invoice(inContext: context)
        invoice.uuid = UUID().uuidString.lowercased()
        invoice.state = JobState.notSend.rawValue
        invoice.date = Date()
        invoice.createdTimestamp = Date()
        invoice.updatedTimestamp = Date()
        
        let defaults = Defaults.currentInvoiceDefaults(in: context)
        invoice.dueTimestamp = moment().add(Int(defaults.due), TimeUnit.Days).date
        invoice.paymentDetails = defaults.paymentDetails
        invoice.note = defaults.note
        
        let account = Account.current(context: context)
        invoice.isStripeActivated = account.isStripeActivated
        invoice.isPayPalActivated = account.paypalId != nil
        
        invoice.language = Locale.current.languageCode
        invoice.currency = Locale.current.currencyCode
        
        return invoice
    }
    
    @discardableResult static func create(from offer: Offer, in context: NSManagedObjectContext) -> Invoice {
        let invoice = Invoice.create(in: context)
        
        invoice.client = offer.client
        invoice.update(from: offer.client)
        
        offer.ordersTyped.forEach { (order) in
            let newOrder = Order.create(from: order, in: context)
            newOrder.itemType = Path(with: invoice).rawValue
            newOrder.item = invoice
        }
        
        offer.attachmentTyped.forEach { (attachment) in
            let newAttachment = Attachment.create(from: attachment, in: context)
            newAttachment.jobType = Path(with: invoice).rawValue
            newAttachment.job = invoice
        }
        
        invoice.isDiscountAbsolute = offer.isDiscountAbsolute
        invoice.discount = offer.discount
        
        invoice.total = offer.total
        invoice.offer = offer
        
        invoice.language = offer.language
        invoice.currency = offer.currency
        
        return invoice
    }
    
    @discardableResult func duplicate(in context: NSManagedObjectContext) -> Invoice {
        let invoice = Invoice.create(in: context)
        
        invoice.client = client
        invoice.update(from: client)
        
        ordersTyped.forEach { (order) in
            let newOrder = Order.create(from: order, in: context)
            newOrder.itemType = Path(with: invoice).rawValue
            newOrder.item = invoice
        }
        
        attachmentTyped.forEach { (attachment) in
            let newAttachment = Attachment.create(from: attachment, in: context)
            newAttachment.jobType = Path(with: invoice).rawValue
            newAttachment.job = invoice
        }
        
        invoice.isDiscountAbsolute = isDiscountAbsolute
        invoice.discount = discount
        
        invoice.paymentDetails = paymentDetails
        invoice.note = note
        
        invoice.isPayPalActivated = isPayPalActivated
        invoice.isStripeActivated = isStripeActivated
        
        invoice.language = language
        invoice.currency = currency
        
        invoice.total = total
        
        return invoice
    }
    
    static func object(withRemoteId remoteId: Int64, in context: NSManagedObjectContext) -> Invoice? {
        let predicate = NSPredicate(format: "remoteId = %d", remoteId)
        return allObjects(matchingPredicate: predicate, context: context).first
    }
}
