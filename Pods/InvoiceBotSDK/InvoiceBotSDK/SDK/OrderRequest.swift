//
//  OrderRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 19/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

public struct OrderRequest {
    
    /// Uploads a given order for a job
    ///
    /// - Parameters:
    ///   - item: we want to upload
    ///   - job: it belongs to
    /// - Returns: updated order
    public static func upload(_ item: Order, for job: Job) -> Observable<Order> {
        
        guard let uuid = item.uuid, let title = item.title, job.remoteId != 0 else {
            return Observable.error(ApiError.parameter)
        }
        
        let description = item.itemDescription ?? ""
        let number = item.number
        let tax = item.tax ?? NSDecimalNumber.zero
        let price = (item.price ?? NSDecimalNumber.zero).asRounded().asPosixString()
        let discount = item.discount ?? NSDecimalNumber.zero
        let total = (item.total ?? NSDecimalNumber.zero).asRounded().asPosixString()
        let quantity = item.quantity ?? NSDecimalNumber.zero
        let path = Path(with: job)
        
        var templateParameter: TemplateParameter = (remoteId: nil, parameter: nil)
        if let template = item.template {
            if template.remoteId != 0 {
                templateParameter = (remoteId: template.remoteId, parameter: nil)
            } else if let uuid = item.template?.uuid, let title = item.template?.title {

                let description = item.template?.itemDescription ?? ""
                let tax = item.template?.tax ?? NSDecimalNumber.zero
                let price = (item.template?.price ?? NSDecimalNumber.zero).asRounded().asPosixString()
                let number = item.template?.number
                
                let parameters = (uuid: uuid, number: number, title: title, description: description, price: price, tax: tax.doubleValue)
                templateParameter = (remoteId: nil, parameter: parameters)
            }
        }
        
        let parameters: OrderParameter = (uuid: uuid, number: number, title: title, description: description, price: price, tax: tax.doubleValue,
                                          discount: discount.doubleValue, isDiscountAbsolute: item.isDiscountAbsolute, total: total,
                                          quantity: quantity.doubleValue, job: job.remoteId, item.sort, template: templateParameter)
        
        let obs = item.hasRemoteId ?
            ApiProvider.request(Api.updateOrder(path: path, id: item.remoteId, parameters: parameters)) :
            ApiProvider.request(Api.createOrder(path: path, parameters: parameters))
        
        return obs.mapJSON().map({ (json) -> Any in
            
            guard let jsonDictionary = json as? JSONDictionary, let templateId = jsonDictionary["template"] as? Int else {
                return json
            }
            item.template?.remoteId = Int64(templateId)
            return json
            
        }).map(updateObjectWithJSON(item))
    }
    
    /// Uploads multiple orders
    ///
    /// - Parameters:
    ///   - items: we want to upload
    ///   - job: they belong to
    /// - Returns: obs when done
    public static func upload(_ items: [Order], for job: Job) -> Observable<Void> {
        
        if items.count == 0 {
            return Observable.empty()
        }
        
        var obs = Observable.just(())
        items.forEach { (item) in
            let upObs = OrderRequest.upload(item, for: job).mapToVoid()
            obs = obs.concat(upObs)
        }
        
        return obs
    }
    
    /// Deletes an order
    ///
    /// - Parameter item: item we want to delete
    /// - Returns: obs when done
    public static func delete(_ item: Order) -> Observable<Order> {
        guard let itemType = item.itemType, let path = Path(rawValue: itemType) else {
            return Observable.error(ApiError.parameter)
        }
        
        return ApiProvider.request(Api.deleteOrder(path: path, id: item.remoteId)).map({ (_) -> Order in
            return item
        })
    }
    
    /// Load orders and insert/update them in a given context
    ///
    /// - Parameter context: to store the changes in
    /// - Returns: Paginated Result
    public static func load(for path: Path, updatedAfter: String?, updateIn context: NSManagedObjectContext) -> Observable<PagedResult<Order>> {
        return Observable.create({ (observer) -> Disposable in
            
            return self.load(for: path, cursor: nil, updatedAfter: updatedAfter, saveIn: context).subscribe(onNext: { (result) in
                
                let nextPageRequest: Observable<PagedResult<Order>>
                
                if let nextPage = result.nextPageCursor {
                    nextPageRequest = self.load(for: path, cursor: nextPage, updatedAfter: updatedAfter, saveIn: context)
                } else {
                    nextPageRequest = .empty()
                }
                
                _ = Observable.just(result)
                    .concat(nextPageRequest)
                    .subscribe(observer)
            })
        })
    }
    
    fileprivate static func load(for path: Path, cursor: String?, updatedAfter: String?, saveIn context: NSManagedObjectContext) -> Observable<PagedResult<Order>> {
        let updateBlock: ((Order, JSONDictionary) -> Order) = { (item, entityJSON) -> Order in
            
            guard let jobId = entityJSON["job"] as? Int64 else { return item }
            
            let job: Job?
            if path == .offer {
              job = Offer.object(withRemoteId: jobId, in: context)
            } else {
              job = Invoice.object(withRemoteId: jobId, in: context)
            }
            item.item = job
            return item
        }
        return ApiProvider.request(Api.listOrders(path: path, cursor: cursor, updatedAfter: updatedAfter)).mapJSON().map(updateObjectsFromJSON(context, manualUpdateBlock: updateBlock))
    }
}
