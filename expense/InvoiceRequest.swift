//
//  InvoiceRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 19/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CoreData
import CoreDataExtensio


struct InvoiceRequest {
    static func upload(_ item: Invoice) -> Observable<Invoice> {
        guard let jobParameters = try? item.parameters(),
            let due = item.dueTimestamp?.ISO8601DateTimeString else {
            return Observable.error(ApiError.parameter)
        }
        
        var parameters: InvoiceParameter = (
            jobParameter: jobParameters,
            due: due,
            paid: item.paidTimestamp?.ISO8601DateTimeString,
            paypal: item.isPayPalActivated,
            stripe: item.isStripeActivated
        )

        return item.needsSignatureUpdate().flatMap { (arg) -> Observable<Invoice> in
            let (data, update) = arg
            parameters.jobParameter.signatureUpdate = update
            parameters.jobParameter.signature = data
            let request = item.hasRemoteId ? Api.updateInvoice(id: item.remoteId, parameters: parameters) : Api.createInvoice(parameters: parameters)
            return ApiProvider.request(request).mapJSON().map(updateObjectWithJSON(item))
        }
    }
    
    static func delete(_ item: Invoice) -> Observable<Invoice> {
        return ApiProvider.request(Api.deleteInvoice(id: item.remoteId)).map { _ -> Invoice in
            return item
        }
    }
    
    static func uploadSignature(_ item: Invoice) -> Observable<Invoice> {
        
        guard
            let path = item.signatureImageName,
            item.signature != nil && item.remoteId != 0
        else {
            return Observable.empty()
        }
        
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return ImageStorage.loadImage(for: path).observeOn(background).map({ (storageItem) -> Data? in
            return UIImagePNGRepresentation(storageItem.image)
        })
        .filterNil()
        .flatMap({ (data) -> Observable<Moya.Response> in
            return ApiProvider.request(Api.updateSignatureData(path: Path.invoice, id: item.remoteId, data: data))
        }).mapJSON().map(updateObjectWithJSON(item))
    }
    
    static func next() -> Observable<String> {
        return ApiProvider.request(Api.nextInvoiceId)
            .mapJSON()
            .map({ (json: Any) -> String in
                guard let json = json as? JSONDictionary, let number = json["number"] as? String else {
                    throw "Invoice number not part of the result"
                }
                return number
            })
    }
    
    /// Load invoices and insert/update them in a given context
    ///
    /// - Parameter context: to store the changes in
    /// - Returns: Paginated Result
    static func load(updatedAfter: String?, updateIn context: NSManagedObjectContext) -> Observable<PagedResult<Invoice>> {
        return Observable.create({ (observer) -> Disposable in
            
            return self.load(cursor: nil, updatedAfter: updatedAfter, saveIn: context).subscribe(onNext: { (result) in
                
                let nextPageRequest: Observable<PagedResult<Invoice>>
                
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
    
    static func load(with remoteId: Int64, context: NSManagedObjectContext) -> Observable<Invoice> {
        return ApiProvider.request(Api.invoice(id: remoteId)).mapJSON()
            .map(updateRemoteItemWithJSON(remoteId, in: context, manualUpdateBlock: InvoiceRequest.updateBlock(in: context)))
    }
    
    fileprivate static func load(cursor: String?, updatedAfter: String?, saveIn context: NSManagedObjectContext) -> Observable<PagedResult<Invoice>> {
        return ApiProvider.request(Api.listInvoices(cursor: cursor, updatedAfter: updatedAfter)).mapJSON()
            .map(updateObjectsFromJSON(context, manualUpdateBlock: InvoiceRequest.updateBlock(in: context)))
    }
    
    fileprivate static func updateBlock(in context: NSManagedObjectContext) -> ((Invoice, JSONDictionary) -> Invoice) {
        return { (item, entityJSON) -> Invoice in
            item.updateSignature()
            guard let clientId = entityJSON["client"] as? Int64 else { return item }
            item.client = Client.object(withRemoteId: clientId, in: context)
            return item
        }
    }
}
