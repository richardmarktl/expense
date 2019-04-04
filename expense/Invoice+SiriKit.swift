//
//  Invoice+SiriKit.swift
//  InVoice
//
//  Created by Georg Kitz on 07.11.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import Intents
import CoreData

@available(iOS 12.0, *)
protocol InvoiceIntentCreatable: class {
    var client: INObject? {get set}
    var items: [INObject]? {get set}
    var total: String? {get set}
    var identifier: String? {get}
    func createJob(in context: NSManagedObjectContext) -> Job
    func update(with job: Job) -> Self?
}

@available(iOS 12.0, *)
extension InvoiceIntentCreatable where Self: INIntent {
    func update(with job: Job) -> Self? {
        guard let clientName = job.clientName else {
            return nil
        }
        client = INObject(identifier: job.client?.uuid, display: clientName)
        items = job.ordersTyped.asSorted().map({ (order) -> INObject in
            let display = order.title ?? order.itemDescription ?? ""
            return INObject(identifier: order.uuid, display: display)
        })
        
        total = job.total?.asRounded().asCurrency(currencyCode: nil)
        return self
    }
}

@available(iOS 12.0, *)
extension CreateInvoiceIntent: InvoiceIntentCreatable {
    func createJob(in context: NSManagedObjectContext) -> Job {
        return Invoice.create(in: context)
    }
}

@available(iOS 12.0, *)
extension SendInvoiceIntent: InvoiceIntentCreatable {
    func createJob(in context: NSManagedObjectContext) -> Job {
        return Invoice.create(in: context)
    }
}

@available(iOS 12.0, *)
extension CreateOfferIntent: InvoiceIntentCreatable {
    func createJob(in context: NSManagedObjectContext) -> Job {
        return Offer.create(in: context)
    }
}

@available(iOS 12.0, *)
extension SendOfferIntent: InvoiceIntentCreatable {
    func createJob(in context: NSManagedObjectContext) -> Job {
        return Offer.create(in: context)
    }
}

@available(iOS 12.0, *)
extension Job {
    
    func createCreateIntent() -> (INIntent & InvoiceIntentCreatable)? {
        let newIntent: INIntent & InvoiceIntentCreatable = self is Invoice ? CreateInvoiceIntent() : CreateOfferIntent()
        return newIntent.update(with: self)
    }
    
    func createSendIntent() -> (INIntent & InvoiceIntentCreatable)? {
        let newIntent: INIntent & InvoiceIntentCreatable = self is Invoice ? SendInvoiceIntent() : SendOfferIntent()
        return newIntent.update(with: self)
    }
    
    class func createFrom(intent: InvoiceIntentCreatable, context: NSManagedObjectContext) -> Job {
        
        let invoice = intent.createJob(in: context)
        
        if let uuid = intent.client?.identifier {
            let client = Client.object(withUuid: uuid, in: context)
            invoice.client = client
            invoice.update(from: client)
        }
        
        intent.items?.forEach { (order) in
            guard
                let uuid = order.identifier,
                let originalOrder = Order.object(withUuid: uuid, in: context)
            else {
                logger.error("Can't find order in database")
                return
            }
            
            let newOrder = Order.create(from: originalOrder, in: context)
            newOrder.item = invoice
            logger.debug("Creating new order")
        }
        
        return invoice
    }
}
