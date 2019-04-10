//
//  JobRequest.swift
//  InVoice
//
//  Created by Richard Marktl on 13.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

public struct JobRequest {
    public static func send(job: Job, with message: String) -> Observable<Void> {
        guard
            let clientName = job.clientName,
            let clientEmail = job.clientEmail
        else {
            return Observable.error(ApiError.parameter)
        }
        
//        let jobType = job.localizedTypeInMiddleOfSentenceKey.localizeFromCurrentSelectedBundle()
//        let text = R.string.localizable.mailMessageText.key.localizeFromCurrentSelectedBundle(clientName, jobType, number, companyName)
        let path = Path(with: job)
        let parameters: SendParameters = (to: clientEmail, text: message, name: clientName, uuid: UUID().uuidString)
        
        return ApiProvider.request(Api.send(path: path, id: job.remoteId, parameters: parameters)).mapToVoid()
    }
}
