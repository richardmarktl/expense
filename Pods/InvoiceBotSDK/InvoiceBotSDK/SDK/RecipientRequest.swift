//
//  RecipientRequest.swift
//  InVoice
//
//  Created by Richard Marktl on 13.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CoreData
import ImageStorage

public struct RecipientRequest {
    
    /// This method will delete all the given recipients.
    ///
    /// - Parameter recipients: an array of recpients
    /// - Returns: an observable
    public static func delete(_ recipients: [Recipient]) -> Observable<Void> {
        if recipients.count == 0 {
            return Observable.empty()
        }
        
        let obs: [Observable<Recipient>] = recipients.map(RecipientRequest.delete)
        
        return Observable.zip(obs).mapToVoid()
    }
    
    /// This method will delete the recipient tracking object on the server.
    ///
    /// - Parameter recipient: the recipient to delete
    /// - Returns: an observable
    public static func delete(_ recipient: Recipient) -> Observable<Recipient> {
        
        guard let job = recipient.job else {
            return Observable.error(ApiError.parameter)
        }
        
        let path = Path(with: job)
        return ApiProvider.request(Api.deleteRecipient(path: path, id: recipient.remoteId)).map({ (_) -> Recipient in
            if let name = recipient.signatureImagePath {
                ImageStorage.deleteImage(in: FileSystemDirectory.imageAttachments, for: name)
            }
            return recipient
        })
    }
    
    public static func uploadSignature(for recipient: Recipient) -> Observable<Recipient> {
            
        guard
            let filename = recipient.signatureName,
            let filePath = recipient.signatureImagePath,
            let job = recipient.job
        else {
            return Observable.error(ApiError.parameter)
        }
        
        let path = Path(with: job)
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return ImageStorage.loadImage(in: FileSystemDirectory.imageAttachments, for: filePath).observeOn(background).map({ (storageItem) -> Data? in
            return storageItem.image.jpegData(compressionQuality: 1.0)
        })
        .filterNil()
        .flatMap({ (data) -> Observable<Moya.Response> in
            return ApiProvider.request(Api.updateRecipientSignature(path: path, id: recipient.remoteId, data: data, filename: filename))
        })
        .mapJSON().map(updateObjectWithJSON(recipient))
    }
    
    /// Load recipients and insert/update them in a given context
    ///
    /// - Parameter context: to store the changes in
    /// - Returns: Paginated Result
    
    public static func load(for path: Path, jobId: Int64? = nil, updateIn context: NSManagedObjectContext) -> Observable<PagedResult<Recipient>> {
        return Observable.create({ (observer) -> Disposable in
            
            return self.load(for: path, cursor: nil, jobId: jobId, saveIn: context).subscribe(onNext: { (result) in
                
                let nextPageRequest: Observable<PagedResult<Recipient>>
                
                if let nextPage = result.nextPageCursor {
                    nextPageRequest = self.load(for: path, cursor: nextPage,  jobId: jobId, saveIn: context)
                } else {
                    nextPageRequest = .empty()
                }
                
                _ = Observable.just(result)
                    .concat(nextPageRequest)
                    .subscribe(observer)
            })
        })
    }
    
    fileprivate static func load(for path: Path, cursor: String?, jobId: Int64?, saveIn context: NSManagedObjectContext) -> Observable<PagedResult<Recipient>> {
        let updateBlock: ((Recipient, JSONDictionary) -> Recipient) = { (item, entityJSON) -> Recipient in
            
            guard let jobId = entityJSON["job"] as? Int64 else { return item }
            
            let job: Job?
            if path == .offer {
                job = Offer.object(withRemoteId: jobId, in: context)
            } else {
                job = Invoice.object(withRemoteId: jobId, in: context)
            }
            item.job = job
            return item
        }
        
        return ApiProvider.request(Api.listRecipients(path: path, cursor: cursor, jobId: jobId, updatedAfter: nil))
            .mapJSON()
            .map(updateObjectsFromJSON(context, manualUpdateBlock: updateBlock))
    }

}
