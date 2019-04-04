//
//  ClientRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 18/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

struct ClientRequest {
    
    /// Upload a changed client
    ///
    /// - Parameter item: we want to upload
    /// - Returns: the updated client object
    static func upload(_ item: Client) -> Observable<Client> {
        
        guard let uuid = item.uuid else {
                return Observable.error(ApiError.parameter)
        }
        
        let parameters: ClientParameter = (uuid: uuid, number: item.number, name: item.name, phone: item.phone, taxId: item.taxId, email: item.email, website: item.website, address: item.address, isActive: item.isActive)
        let obs = item.hasRemoteId ? ApiProvider.request(Api.updateClient(id: item.remoteId, parameters: parameters)) : ApiProvider.request(Api.createClient(parameters: parameters))
        
        return obs.mapJSON().map(updateObjectWithJSON(item))
    }
    
    /// Deletes a client from the server
    ///
    /// - Parameter item: we want to delete
    /// - Returns: the client that was deleted
    static func delete(_ item: Client) -> Observable<Client> {
        return ApiProvider.request(Api.deleteClient(id: item.remoteId)).map({ (_) -> Client in
            return item
        })
    }
    
    /// Load clients and insert/update them in a given context
    ///
    /// - Parameter context: to store the changes in
    /// - Returns: Paginated Result
    static func load(updatedAfter: String?, updateIn context: NSManagedObjectContext) -> Observable<PagedResult<Client>> {
        return Observable.create({ (observer) -> Disposable in
            
            return self.load(updatedAfter: updatedAfter, cursor: nil, saveIn: context).subscribe(onNext: { (result) in
                
                let nextPageRequest: Observable<PagedResult<Client>>
                
                if let nextPage = result.nextPageCursor {
                    nextPageRequest = self.load(updatedAfter: updatedAfter, cursor: nextPage, saveIn: context)
                } else {
                    nextPageRequest = .empty()
                }
                
                _ = Observable.just(result)
                    .concat(nextPageRequest)
                    .subscribe(observer)
            })
        })
    }
    
    fileprivate static func load(updatedAfter: String?, cursor: String?, saveIn context: NSManagedObjectContext) -> Observable<PagedResult<Client>> {
            return ApiProvider.request(Api.listClients(cursor: cursor, updatedAfter: updatedAfter)).mapJSON().map(updateObjectsFromJSON(context))
    }
}
