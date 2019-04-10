//
//  ApiStubbing.swift
//  InvoiceBotSDK
//
//  Created by Georg Kitz on 09.04.19.
//  Copyright © 2019 Georg Kitz. All rights reserved.
//

import Foundation

enum StubError: Error {
    case noPath
}

//swiftlint:disable force_try
func stubbedResponse(_ filename: String, parameters: [CVarArg] = []) -> Data! {
    
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    do {
        guard let path = bundle.path(forResource: filename, ofType: "json") else {
            throw StubError.noPath
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
