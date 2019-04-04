//
//  ApiLogger.swift
//  InVoice
//
//  Created by Georg Kitz on 22/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import Moya
import Result
import class Alamofire.Request

class ApiLogger: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        let requestTrackingId = request.request?.allHTTPHeaderFields?["t"] ?? "no-id"
        logger.verbose("\(requestTrackingId)\n\(Date()) - URL: \(request.request!.url!.absoluteString), Method: \(target.method)")
        logger.verbose(request.request?.allHTTPHeaderFields ?? [:])
        
        // we don't want to print out the base64 string of the image or any other stuff that's why we check the data
        // and clean values from it
        if target.method.isWrite {
           logger.verbose("DATA: \(target.task.clean()))")
        }
        
        logger.verbose("\n")
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .failure(let error):
            
            switch error {
            case .imageMapping(let response),
                 .jsonMapping(let response),
                 .objectMapping(_, let response),
                 .statusCode(let response),
                 .stringMapping(let response):
                let requestTrackingId = response.request?.allHTTPHeaderFields?["t"] ?? "no-id"
                logger.error("\(requestTrackingId)")
            case .underlying(_, let response):
                if let response = response {
                    let requestTrackingId = response.request?.allHTTPHeaderFields?["t"] ?? "no-id"
                    logger.error("\(requestTrackingId)")
                } else {
                    //swiftlint:disable fallthrough
                    fallthrough
                    //swiftlint:enable fallthrough
                }
            default:
                logger.error("No Tracking Id")
            }
            
            logger.error("\n\(Date()) - URL: \(target.path), Error: \(error)\n")
            
        case .success(let response):
            let requestTrackingId = response.request?.allHTTPHeaderFields?["t"] ?? "no-id"
            let url = response.response?.url?.absoluteString ?? "no-url"
            logger.verbose("\(requestTrackingId)\n\(Date()) - URL: \(url), StatusCode: \(response.statusCode)")
            
            // improve the json string for a better human readeablity
            if let string = try? response.mapString(),
                let data = string.data(using: .utf8),
                let jsonString = String(data: data, encoding: .utf8) {
                logger.verbose("DATA: \(jsonString)\n")
            } else {
                logger.verbose("DATA: was not able to parse the json data")
            }
        }
    }
}
