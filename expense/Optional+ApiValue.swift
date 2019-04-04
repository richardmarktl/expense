//
//  Optional+ApiValue.swift
//  InVoice
//
//  Created by Georg Kitz on 19/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    var apiValue: Any {
        guard let value = self, !value.isEmpty else {
            return NSNull()
        }
        return value
    }
}

extension Optional where Wrapped == String {
    var databaseValue: Wrapped? {
        if let value = self {
            let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedValue.isEmpty == false {
                return trimmedValue
            }
        }
        return nil
    }
    
    var removeWhitespaces: Wrapped? {
        if let value = self {
            let trimmedValue = value.replacingOccurrences(of: " ", with: "")
            if trimmedValue.isEmpty == false {
                return trimmedValue
            }
        }
        return nil
    }
    
    var notNil: String {
        if let value = self {
            return value
        }
        return ""
    }
}

extension Optional where Wrapped == Bool {
    var apiValue: Any {
        guard let value = self else {
            return false
        }
        return value
    }
}

extension Optional where Wrapped == Double {
    var apiValue: Any {
        guard let value = self else {
            return NSNull()
        }
        return value
    }
}
