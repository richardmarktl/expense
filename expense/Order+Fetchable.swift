//
//  ItemTemplate+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreDataExtensio
import CoreData
import RxSwift

extension Order: Fetchable, Createable {
    
    public typealias CreatedType = Order
    public typealias FetchableType = Order
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func rxOrders(for job: Job, in context: NSManagedObjectContext) -> Observable<[Order]> {
        let predicate = NSPredicate(format: "item = %@", job)
        return Order.rxMonitorChanges(context).startWith((inserted: [], updated: [], deleted: [])).map({ _ in
            return Order.allObjects(matchingPredicate: predicate, context: context)
        })
    }
    
    func calculateTotal() {
        
        guard let price = price, let quantity = quantity else {
            return 
        }
        
        var value = price * quantity
        if let discount = discount {
            
            if isDiscountAbsolute {
                value -= discount
            } else {
                value = value * (1 - discount / 100)
            }
        }
        
        total = value.asRounded()
    }
    
    static func create(in context: NSManagedObjectContext) -> Order {
        let order = Order(inContext: context)
        order.uuid = UUID().uuidString.lowercased()
        order.number = order.uuid?.shortenedUUIDString
        order.createdTimestamp = Date()
        order.updatedTimestamp = Date()
        order.localUpdateTimestamp = Date()
        order.quantity = NSDecimalNumber(value: 1)
        return order
    }
    
    static func create(from order: Order, in context: NSManagedObjectContext) -> Order {
        let newOrder = Order.create(in: context)
        newOrder.discount = order.discount
        newOrder.isDiscountAbsolute = order.isDiscountAbsolute
        newOrder.quantity = order.quantity
        newOrder.template = order.template
        newOrder.total = order.total
        newOrder.itemDescription = order.itemDescription
        newOrder.price = order.price
        newOrder.tax = order.tax
        newOrder.title = order.title
        newOrder.sort = order.sort
        return newOrder
    }
    
    func update(from item: Item) {
        itemDescription = item.itemDescription
        tax = item.tax
        price = item.price
        template = item
        number = item.number
    }
    
    func update(job: Job) {
        item = job
        itemType = Path(with: job).rawValue
    }
}
