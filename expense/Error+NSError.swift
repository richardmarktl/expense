//
//  Error+NSError.swift
//  InVoice
//
//  Created by Georg Kitz on 5/30/18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

extension Int {
    var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Bool {
    var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension String {
    var asNSString: NSString {
        return self as NSString
    }
}
