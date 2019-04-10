//
//  DefaultsRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 19.02.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

public struct DefaultsRequest {
    public static func upload(_ defaults: Defaults) -> Observable<Defaults> {
        
        guard
            let type = defaults.type,
            let path = Path(rawValue: type),
            let note = defaults.note,
            let paymentDetails = defaults.paymentDetails,
            let message = defaults.message,
            let prefix = defaults.prefix
            else {
            return Observable.error(ApiError.parameter)
        }
        let parameters: DefaultsParameters = (
            note: note,
            paymentDetails: paymentDetails,
            message: message,
            prefix: prefix,
            start: defaults.start,
            minimumLength: defaults.minimumLength,
            due: defaults.due
        )
        return ApiProvider.request(Api.updateDefaults(path: path, parameter: parameters)).mapJSON().map(updateObjectWithJSON(defaults))
    }
    
    public static func load(_ defaults: Defaults, updatedAfter: String?) -> Observable<Defaults> {
        guard
            let type = defaults.type,
            let path = Path(rawValue: type)
            else {
                return Observable.error(ApiError.parameter)
        }
        return ApiProvider.request(Api.defaults(path: path, updatedAfter: updatedAfter)).mapJSON().map(updateObjectWithJSON(defaults))
    }
}
