//
//  UrlValidator.swift
//  InVoice
//
//  Created by Georg Kitz on 24.11.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

struct UrlValidator {
    static func validate(urlString: String) -> Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.endIndex.encodedOffset)) {
            return match.range.length == urlString.endIndex.encodedOffset
        } else {
            return false
        }
    }
}
