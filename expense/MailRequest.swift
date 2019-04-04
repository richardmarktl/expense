//
//  MailRequest.swift
//  InVoice
//
//  Created by Richard Marktl on 19.02.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import Moya

struct MailRequest {
    static func sendJob(_ item: Job, mail: MailParameter) -> Observable<Job> {
        guard let jobParameters = try? item.parameters() else {
            return Observable.error(ApiError.parameter)
        }
        
        let path = Path(with: item)
        var due: String = ""
        var paid: String?
        var paypal: Bool?
        var stripe: Bool?
        if path == .invoice {
            if let invoice = item as? Invoice, let timestamp = invoice.dueTimestamp {
                due = timestamp.ISO8601DateTimeString
                paid = invoice.paidTimestamp?.ISO8601DateTimeString
                paypal = invoice.isPayPalActivated
                stripe = invoice.isStripeActivated
            } else {
                return Observable.error(ApiError.parameter)
            }
        }
        
        var parameters: InvoiceParameter = (
            jobParameter: jobParameters,
            due: due,
            paid: paid,
            paypal: paypal,
            stripe: stripe
        )
        
        return item.needsSignatureUpdate().flatMap { (arg) -> Observable<Job> in
            let (data, update) = arg
            parameters.jobParameter.signatureUpdate = update
            parameters.jobParameter.signature = data
            let request = item.hasRemoteId ? Api.sendJob(path: path, id: item.remoteId, parameters: parameters, mail: mail) :
                Api.sendNewJob(path: path, parameters: parameters, mail: mail)
            return ApiProvider.request(request).mapJSON().map(updateObjectWithJSON(item))
        }
    }
    
    static func delete(_ item: Offer) -> Observable<Offer> {
        return ApiProvider.request(Api.deleteOffer(id: item.remoteId)).map { _ -> Offer in
            return item
        }
    }
}
