//
//  PaymentRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 22/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

public struct PaymentRequest {
    
    public static func upload(_ item: Payment, for job: Job) -> Observable<Payment> {
        
        guard let uuid = item.uuid, let date = item.paymentDate, let amount = item.amount, let type = item.type, job.remoteId != 0 else {
            return Observable.error(ApiError.parameter)
        }
        
        let parameters: PaymentParameter = (uuid: uuid, amount: amount.asRounded().asPosixString(), type: type, date: date.ISO8601DateTimeString, note: item.note, job: job.remoteId)
        
        let obs = item.hasRemoteId ?
            ApiProvider.request(Api.updatePayment(id: item.remoteId, parameters: parameters)) :
            ApiProvider.request(Api.createPayment(parameters: parameters))
        
        return obs.mapJSON().map(updateObjectWithJSON(item))
    }
    
    public static func upload(_ items: [Payment], for job: Job) -> Observable<Void> {
        
        if items.count == 0 {
            return Observable.empty()
        }
        
        var obs = Observable.just(())
        items.forEach { (item) in
            let upObs = PaymentRequest.upload(item, for: job).mapToVoid()
            obs = obs.concat(upObs)
        }
        
        return obs
    }
    
    public static func delete(_ item: Payment) -> Observable<Payment> {
        return ApiProvider.request(Api.deletePayment(id: item.remoteId)).map({ (_) -> Payment in
            return item
        })
    }
    
    public static func load(for invoiceId: Int64? = nil, updatedAfter: String?, updateIn context: NSManagedObjectContext) -> Observable<PagedResult<Payment>> {
        return Observable.create({ (observer) -> Disposable in
            
            return self.load(cursor: nil, for: invoiceId, updatedAfter: updatedAfter, saveIn: context).subscribe(onNext: { (result) in
                
                let nextPageRequest: Observable<PagedResult<Payment>>
                
                if let nextPage = result.nextPageCursor {
                    nextPageRequest = self.load(cursor: nextPage, for: invoiceId, updatedAfter: updatedAfter, saveIn: context)
                } else {
                    nextPageRequest = .empty()
                }
                
                _ = Observable.just(result)
                    .concat(nextPageRequest)
                    .subscribe(observer)
            })
        })
    }
    
    fileprivate static func load(cursor: String?, for invoiceId: Int64?, updatedAfter: String?, saveIn context: NSManagedObjectContext) -> Observable<PagedResult<Payment>> {
        let updateBlock: ((Payment, JSONDictionary) -> Payment) = { (item, entityJSON) -> Payment in
            
            guard let jobId = entityJSON["invoice"] as? Int64 else { return item }
            item.invoice = Invoice.object(withRemoteId: jobId, in: context)
            
            return item
        }
        return ApiProvider.request(Api.listPayments(cursor: cursor, invoiceId: invoiceId, updatedAfter: updatedAfter)).mapJSON().map(updateObjectsFromJSON(context, manualUpdateBlock: updateBlock))
    }
}
