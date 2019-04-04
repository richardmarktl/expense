//
//  ItemRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 19/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

struct ItemRequest {
    
    static func upload(_ item: Item) -> Observable<Item> {
        
        guard let uuid = item.uuid, let title = item.title else {
            return Observable.error(ApiError.parameter)
        }
        
        let description = item.itemDescription ?? ""
        let tax = item.tax ?? NSDecimalNumber.zero
        let price = (item.price ?? NSDecimalNumber.zero).asRounded().asPosixString()
        let number = item.number
        
        let parameters: ItemParameter = (uuid: uuid, number: number, title: title, description: description, price: price, tax: tax.doubleValue)
        let obs = item.hasRemoteId ? ApiProvider.request(Api.updateItem(id: item.remoteId, parameters: parameters)) : ApiProvider.request(Api.createItem(parameters: parameters))
        
        return obs.mapJSON().map(updateObjectWithJSON(item))
    }
    
    static func delete(_ item: Item) -> Observable<Item> {
        return ApiProvider.request(Api.deleteItem(id: item.remoteId)).mapToVoid().map({ (_) -> Item in
            return item
        })
    }
    
    /// Load invoices and insert/update them in a given context
    ///
    /// - Parameter context: to store the changes in
    /// - Returns: Paginated Result
    static func load(updatedAfter: String?, updateIn context: NSManagedObjectContext) -> Observable<PagedResult<Item>> {
        return Observable.create({ (observer) -> Disposable in
            
            return self.load(cursor: nil, updatedAfter: updatedAfter, saveIn: context).subscribe(onNext: { (result) in
                
                let nextPageRequest: Observable<PagedResult<Item>>
                
                if let nextPage = result.nextPageCursor {
                    nextPageRequest = self.load(cursor: nextPage, updatedAfter: updatedAfter, saveIn: context)
                } else {
                    nextPageRequest = .empty()
                }
                
                _ = Observable.just(result)
                    .concat(nextPageRequest)
                    .subscribe(observer)
            })
        })
    }
    
    fileprivate static func load(cursor: String?, updatedAfter: String?, saveIn context: NSManagedObjectContext) -> Observable<PagedResult<Item>> {
        return ApiProvider.request(Api.listItems(cursor: cursor, updatedAfter: updatedAfter)).mapJSON().map(updateObjectsFromJSON(context))
    }
}
