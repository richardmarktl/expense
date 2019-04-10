//
//  OfferRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 18/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CoreData
import CoreDataExtensio
import ImageStorage

public enum OfferRequestError: Error {
    case nextNumberNotPartOfResult
}

public struct OfferRequest {
    
    public static func upload(_ item: Offer) -> Observable<Offer> {
        guard var parameters = try? item.parameters() else {
            return Observable.error(ApiError.parameter)
        }
        
        return item.needsSignatureUpdate().flatMap { (arg) -> Observable<Offer> in
            let (data, update) = arg
            parameters.signatureUpdate = update
            parameters.signature = data
            let request = item.hasRemoteId ? Api.updateOffer(id: item.remoteId, parameters: parameters) : Api.createOffer(parameters: parameters)
            return ApiProvider.request(request).mapJSON().map(updateObjectWithJSON(item))
        }
    }
    
    public static func delete(_ item: Offer) -> Observable<Offer> {
        return ApiProvider.request(Api.deleteOffer(id: item.remoteId)).map { _ -> Offer in
            return item
        }
    }
    
    public static func uploadSignature(_ item: Offer) -> Observable<Offer> {
        
        guard
            let path = item.signatureImageName,
            item.signature != nil && item.remoteId != 0
            else {
                return Observable.empty()
        }
        
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return ImageStorage.loadImage(in: FileSystemDirectory.imageAttachments, for: path).observeOn(background).map({ (storageItem) -> Data? in
            return storageItem.image.pngData()
        })
        .filterNil()
        .flatMap({ (data) -> Observable<Moya.Response> in
            return ApiProvider.request(Api.updateSignatureData(path: Path.offer, id: item.remoteId, data: data))
        }).mapJSON().map(updateObjectWithJSON(item))
    }
    
    public static func next() -> Observable<String> {
        return ApiProvider.request(Api.nextOfferId)
            .mapJSON()
            .map({ (json: Any) -> String in
                guard let json = json as? JSONDictionary, let number = json["number"] as? String else {
                    throw OfferRequestError.nextNumberNotPartOfResult
                }
                return number
            })
    }
    
    /// Load invoices and insert/update them in a given context
    ///
    /// - Parameter context: to store the changes in
    /// - Returns: Paginated Result
    public static func load(updatedAfter: String?, updateIn context: NSManagedObjectContext) -> Observable<PagedResult<Offer>> {
        return Observable.create({ (observer) -> Disposable in
            
            return self.load(cursor: nil, updatedAfter: updatedAfter, saveIn: context).subscribe(onNext: { (result) in
                
                let nextPageRequest: Observable<PagedResult<Offer>>
                
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
    
    public static func load(with remoteId: Int64, context: NSManagedObjectContext) -> Observable<Offer> {
        return ApiProvider.request(Api.offer(id: remoteId)).mapJSON().map(updateRemoteItemWithJSON(remoteId, in: context, manualUpdateBlock: OfferRequest.updateBlock(in: context)))
    }
    
    fileprivate static func load(cursor: String?, updatedAfter: String?, saveIn context: NSManagedObjectContext) -> Observable<PagedResult<Offer>> {
        return ApiProvider.request(Api.listOffers(cursor: cursor, updatedAfter: updatedAfter)).mapJSON().map(updateObjectsFromJSON(context, manualUpdateBlock: OfferRequest.updateBlock(in: context)))
    }
    
    fileprivate static func updateBlock(in context: NSManagedObjectContext) -> ((Offer, JSONDictionary) -> Offer) {
        return { (item, entityJSON) -> Offer in
            item.updateSignature()
            guard let clientId = entityJSON["client"] as? Int64 else { return item }
            item.client = Client.object(withRemoteId: clientId, in: context)
            return item
        }
    }
}
