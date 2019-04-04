//
//  Mailchimp.swift
//  InVoice
//
//  Created by Georg Kitz on 22/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import Moya
import RxSwift

enum Mailchimp: TargetType {
    
    case addMember(email: String)
    
    var baseURL: URL {
        return URL(string: "https://us17.api.mailchimp.com/3.0/")!
    }
    
    var path: String {
        switch self {
        case .addMember:
            return "lists/253732c515/members/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addMember:
            return Moya.Method.post
        }
    }
    
    var sampleData: Data {
        switch self {
        case .addMember:
            return stubbedResponse("mailchimp")
        }
    }
    
    var task: Task {
        switch self {
        case .addMember(let email):
            
            var params: [String: Any] = [:]
            params["email_address"] = email
            params["status"] = "subscribed"
            params["merge_fields"] = ["FNAME": "", "LNAME": ""]
            
            return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}

//swiftlint:disable force_try
func stubbedResponse(_ filename: String, parameters: [CVarArg] = []) -> Data! {
    
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    do {
        guard let path = bundle.path(forResource: filename, ofType: "json") else {
            throw "No Path"
        }
        let string = try String(contentsOfFile: path)
        let formattedString = String(format: string, arguments: parameters)
        
        return formattedString.data(using: String.Encoding.utf8)!
    } catch {
        logger.error("Failed to load stub for \(filename) with \(error)")
        return "{}".data(using: String.Encoding.utf8)!
    }
}
//swiftlint:enable force_try
