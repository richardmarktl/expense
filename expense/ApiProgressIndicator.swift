//
//  ApiProgressIndicator.swift
//  meisterwork
//
//  Created by Georg Kitz on 26/02/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

import Foundation
import Moya
import Result

struct ApiProgressIndicator: PluginType {
    
    fileprivate static var requestCounter = 0
    
    func willSend(_ request: RequestType, target: TargetType) {
        ApiProgressIndicator.requestCounter += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        
        ApiProgressIndicator.requestCounter -= 1
        
        if ApiProgressIndicator.requestCounter == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
