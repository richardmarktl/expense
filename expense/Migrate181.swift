//
//  Migrate181.swift
//  InVoice
//
//  Created by Georg Kitz on 27.03.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

struct Migrate181 {
    static func migrate(context: NSManagedObjectContext) -> Observable<Void> {
        var obs = Observable.just(())
        let predicate = NSPredicate(format: "number == NULL")
        
        let clientsWithoutId = Client.allObjects(matchingPredicate: predicate, context: context)
        clientsWithoutId.forEach({ (client) in
            client.number = client.uuid?.shortenedUUIDString
            client.localUpdateTimestamp = Date()
            obs = obs.concat(ClientRequest.upload(client).catchErrorJustReturn(client).mapToVoid().take(1))
        })
        
        let ordersWithoutId = Order.allObjects(matchingPredicate: predicate, context: context)
        ordersWithoutId.forEach({ (order) in
            order.number = order.template?.uuid?.shortenedUUIDString ?? order.uuid?.shortenedUUIDString
            order.localUpdateTimestamp = Date()
            
            let request: Observable<Order>
            if let job = order.item {
                request = OrderRequest.upload(order, for: job)
            } else {
                request = Observable.just(order)
            }
            obs = obs.concat(request.catchErrorJustReturn(order).mapToVoid().take(1))
        })
        
        let itemsWithoutId = Item.allObjects(matchingPredicate: predicate, context: context)
        itemsWithoutId.forEach({ (item) in
            item.number = item.uuid?.shortenedUUIDString
            item.localUpdateTimestamp = Date()
            obs = obs.concat(ItemRequest.upload(item).catchErrorJustReturn(item).mapToVoid().take(1))
        })
        
        if let jobDesign = JobDesign.allObjects(context: context).first {
            jobDesign.showArticleNumber = false
            jobDesign.showArticleTitle = true
            jobDesign.showArticleDescription = true
            jobDesign.localUpdateTimestamp = Date()
            obs = obs.concat(JobDesignRequest.upload(jobDesign).catchErrorJustReturn(jobDesign).mapToVoid().take(1))
        }
        
        let jobPredicate = NSPredicate(format: "clientNumber == NULL AND client != NULL")
        let invoicesWithoutClientNumber = Invoice.allObjects(matchingPredicate: jobPredicate, context: context)
        invoicesWithoutClientNumber.forEach({ (item) in
            item.clientNumber = item.client?.number
            item.localUpdateTimestamp = Date()
            obs = obs.concat(JobRequest.send(job: item).catchErrorJustReturn(()).mapToVoid().take(1))
        })
        
        let offersWithoutClientNumber = Offer.allObjects(matchingPredicate: jobPredicate, context: context)
        offersWithoutClientNumber.forEach({ (item) in
            item.clientNumber = item.client?.number
            item.localUpdateTimestamp = Date()
            obs = obs.concat(JobRequest.send(job: item).catchErrorJustReturn(()).mapToVoid().take(1))
        })
        
        try? context.save()
        
        return obs.takeLast(1).do(onNext: { (_) in
            try? context.save()
        })
    }
}
