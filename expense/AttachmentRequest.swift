//
//  AttachmentRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 22/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CoreData

struct AttachmentRequest {
    
    static func upload(_ item: Attachment, for job: Job) -> Observable<Attachment> {
        
        guard let uuid = item.uuid, let filename = item.fileName, job.remoteId != 0 else {
            return Observable.error(ApiError.parameter)
        }
        
        let remoteId = job.remoteId
        let path = Path(with: job)
        
        let obs = item.hasRemoteId ?
            ApiProvider.request(Api.updateAttachment(path: path, id: item.remoteId, filename: filename, sort: item.sort))
            : create(with: uuid, filename: filename, remoteId: remoteId, sort: item.sort, path: path, attachmentRemoteId: nil)
        
        return obs.mapJSON().map(updateObjectWithJSON(item))
    }
    
    static func upload(_ items: [Attachment], for job: Job) -> Observable<Void> {
        
        if items.count == 0 {
            return Observable.empty()
        }
        
        var obs = Observable.just(())
        items.forEach { (item) in
            let upObs = AttachmentRequest.upload(item, for: job).mapToVoid()
            obs = obs.concat(upObs)
        }
        
        return obs
    }
    
    static func delete(_ item: Attachment) -> Observable<Attachment> {
        guard let jobType = item.jobType, let path = Path(rawValue: jobType) else {
            return Observable.error(ApiError.parameter)
        }
        
        return ApiProvider.request(Api.deleteAttachment(path: path, id: item.remoteId)).map({ (_) -> Attachment in
            if let uuid = item.uuid {
                ImageStorage.deleteImage(for: uuid)
            }
            return item
        })
    }
    
    static func uploadAttachmentContent(_ item: Attachment) -> Observable<Attachment> {
        guard
            let job = item.job,
            let uuid = item.uuid,
            let filename = item.fileName,
            item.remoteId != 0 && job.remoteId != 0
        else {
            return Observable.error(ApiError.parameter)
        }
        
        let remoteId = job.remoteId
        let path = Path(with: job)
        return create(with: uuid, filename: filename, remoteId: remoteId, sort: item.sort, path: path, attachmentRemoteId: item.remoteId)
            .mapJSON().map(updateObjectWithJSON(item))
    }
    
    private static func create(with uuid: String, filename: String, remoteId: Int64, sort: Int16, path: Path, attachmentRemoteId: Int64?) -> Observable<Moya.Response> {
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return ImageStorage.loadImage(for: uuid).observeOn(background).map({ (storageItem) -> Data? in
            return UIImageJPEGRepresentation(storageItem.image, 1.0)
        })
        .filterNil()
        .flatMap({ (data) -> Observable<Moya.Response> in
            let parameter: AttachmentParameter = (uuid: uuid, fileName: filename, mimeType: "image/jpeg", data: data, sort: sort, job: remoteId)
            if let attachmentRemoteId = attachmentRemoteId {
                return ApiProvider.request(Api.updateAttachmentData(path: path, id: attachmentRemoteId, parameters: parameter))
            } else {
                return ApiProvider.request(Api.createAttachment(path: path, parameters: parameter))
            }
        })
    }
    
    /// Load invoices and insert/update them in a given context
    ///
    /// - Parameter context: to store the changes in
    /// - Returns: Paginated Result
    static func load(for path: Path, updatedAfter: String?, updateIn context: NSManagedObjectContext) -> Observable<PagedResult<Attachment>> {
        return Observable.create({ (observer) -> Disposable in
            
            return self.load(for: path, cursor: nil, updatedAfter: updatedAfter, saveIn: context).subscribe(onNext: { (result) in
                
                let nextPageRequest: Observable<PagedResult<Attachment>>
                
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
    
    fileprivate static func load(for path: Path, cursor: String?, updatedAfter: String?, saveIn context: NSManagedObjectContext) -> Observable<PagedResult<Attachment>> {
        let updateBlock: ((Attachment, JSONDictionary) -> Attachment) = { (item, entityJSON) -> Attachment in
            
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
        return ApiProvider.request(Api.listAttachments(path: path, cursor: cursor, updatedAfter: updatedAfter)).mapJSON().map(updateObjectsFromJSON(context, manualUpdateBlock: updateBlock))
    }
}
