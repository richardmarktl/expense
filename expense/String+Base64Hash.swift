//
//  String+Base64Hash.swift
//  InVoice
//
//  Created by Georg Kitz on 14.11.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

extension String {
    var sha256AsBase64:String? {
        guard let stringData = self.data(using: String.Encoding.utf8) else { return nil }
        return digest(input: stringData as NSData).base64EncodedString(options: [])
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
}
