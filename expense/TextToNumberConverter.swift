//
//  TextToNumberConverter.swift
//  InVoice
//
//  Created by Richard Marktl on 01.12.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

/// This class is used to support the speech recognition for numbers. The converter will convert numbers
/// from any format to computer readable format.
/// It will also convert string numbers like (one, two, three) into numbers. This is a naive implementation but
/// it will work for the first version.
class TextToNumberConverter {
    /// This translates strings into numbers.
    private let converter: [String: String] = [
        R.string.localizable.zero(): "0",
        R.string.localizable.one(): "1",
        R.string.localizable.two(): "2",
        R.string.localizable.three(): "3",
        R.string.localizable.four(): "4",
        R.string.localizable.five(): "5",
        R.string.localizable.six(): "6",
        R.string.localizable.seven(): "7",
        R.string.localizable.eight(): "8",
        R.string.localizable.nine(): "9",
        R.string.localizable.ten(): "10",
        R.string.localizable.eleven(): "11",
        R.string.localizable.twelve(): "12",
        R.string.localizable.once(): "1",
        R.string.localizable.twice(): "2"
    ]
    
    private let times: String = R.string.localizable.times()
    private let decimalSeperator: String
    private let groupingSeperator: String
    
    init() {
        decimalSeperator = Locale.current.decimalSeparator ?? "."
        groupingSeperator = Locale.current.groupingSeparator ?? ""
    }
    
    /// This method will convert a string into a NSDecimalNumber object.
    ///
    /// - Parameters:
    ///   - string: the string to convert
    ///   - value: the optional replacement
    /// - Returns: the decimal number or the replacement
    public func convert(_ string: String, replacement: NSDecimalNumber = NSDecimalNumber(decimal: 1.0)) -> NSDecimalNumber {
        if string.isEmpty {
            return replacement
        }
        
        // rmove the times string iterate through the string numbers and replace them.
        var result = string.lowercased().replacingOccurrences(of: times, with: "")
        for item in converter {
            result = result.replacingOccurrences(of: item.key, with: item.value)
        }
        // now remove all none numeric chars
        result = result.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.,").inverted)
        result = result.removingWhitespaces()
        
        // now remove convert the number to computer read able format
        result = result.replacingOccurrences(of: groupingSeperator, with: "")
        result = result.replacingOccurrences(of: decimalSeperator, with: ".")
        
        return result.isEmpty ? replacement : NSDecimalNumber(string: result)
    }
}
