//
//  JobLocalizationRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 19.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

struct JobLocalizationRequest {
    
    static func upload(_ localization: JobLocalization) -> Observable<JobLocalization> {
        guard let language = localization.language, let uuid = localization.uuid else {
            return Observable.error(ApiError.parameter)
        }
        
        let parameters: LocalizationParameters = (
            uuid: uuid,
            paymentDetailsTitle: localization.paymentDetailsTitle,
            headerArticle: localization.headerArticle,
            invoiceNumberTitle: localization.invoiceNumberTitle,
            headerPrice: localization.headerPrice,
            offerNumberTitle: localization.offerNumberTitle,
            offerTitle: localization.offerTitle,
            vatsTitle: localization.vatsTitle,
            invoiceTitle: localization.invoiceTitle,
            language: language,
            discountTitle: localization.discountTitle,
            dateTitle: localization.dateTitle,
            headerTotal: localization.headerTotal,
            balanceTitle: localization.balanceTitle,
            subtotalTitle: localization.subtotalTitle,
            headerQuantity: localization.headerQuantity,
            dueDateTitle: localization.dueDateTitle,
            paidTitle: localization.paidTitle,
            headerDescription: localization.headerDescription,
            headerArticleNumber: localization.headerArticleNumber
        )
        
        let obs = localization.hasRemoteId ?
            ApiProvider.request(Api.updateLocalization(id: localization.remoteId, parameters: parameters)) :
            ApiProvider.request(Api.createLocalization(parameters: parameters))
        return obs.mapJSON().map(updateObjectWithJSON(localization))
    }
    
    static func delete(_ item: JobLocalization) -> Observable<JobLocalization> {
        return ApiProvider.request(Api.deleteLocalization(id: item.remoteId)).map { _ -> JobLocalization in
            return item
        }
    }
    
    static func load(updatedAfter: String?, updateIn context: NSManagedObjectContext) -> Observable<PagedResult<JobLocalization>> {
        return Observable.create({ (observer) -> Disposable in
            
            return self.load(cursor: nil, updatedAfter: updatedAfter, saveIn: context).subscribe(onNext: { (result) in
                
                let nextPageRequest: Observable<PagedResult<JobLocalization>>
                
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
    
    fileprivate static func load(cursor: String?, updatedAfter: String?, saveIn context: NSManagedObjectContext) -> Observable<PagedResult<JobLocalization>> {
        return ApiProvider.request(Api.listLocalization(cursor: cursor, updateAfter: updatedAfter)).mapJSON().map(updateObjectsFromJSON(context))
    }
}
