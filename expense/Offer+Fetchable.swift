//
//  Job+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 12/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio

extension Offer: Fetchable {

    public typealias FetchableType = Offer
    public typealias I = String

    public static func idName() -> String {
        return "uuid"
    }

    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    static func create(in context: NSManagedObjectContext) -> Offer {
        let offer = Offer(inContext: context)
        offer.uuid = UUID().uuidString.lowercased()
        offer.state = JobState.notSend.rawValue
        offer.date = Date()
        offer.createdTimestamp = Date()
        offer.updatedTimestamp = Date()
        offer.localUpdateTimestamp = offer.updatedTimestamp
        
        let defaults = Defaults.currentOfferDefaults(in: context)
        offer.paymentDetails = defaults.paymentDetails
        offer.note = defaults.note
        
        offer.language = Locale.current.languageCode
        offer.currency = Locale.current.currencyCode
        
        return offer
    }
    
    func duplicate(in context: NSManagedObjectContext) -> Offer {
        let offer = Offer.create(in: context)
        
        offer.client = client
        offer.update(from: client)
        
        ordersTyped.forEach { (order) in
            let newOrder = Order.create(from: order, in: context)
            newOrder.itemType = Path(with: offer).rawValue
            newOrder.item = offer
        }
        
        attachmentTyped.forEach { (attachment) in
            let newAttachment = Attachment.create(from: attachment, in: context)
            newAttachment.jobType = Path(with: offer).rawValue
            newAttachment.job = offer
        }
        
        offer.isDiscountAbsolute = isDiscountAbsolute
        offer.discount = discount
        offer.total = total
        
        offer.language = language
        offer.currency = currency
        
        return offer
    }
}
