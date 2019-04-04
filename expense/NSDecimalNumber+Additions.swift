//
//  NSDecimalNumber+Additions.swift
//  meisterwork
//
//  Created by Georg Kitz on 17/03/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

import Foundation

extension NSDecimalNumber {
    
    struct Static {
        static let formatter = NumberFormatter()
    }
    
    func asCurrency(_ decimals: Int16 = 2, currencyCode: String?) -> String {
        let roundingBehaviour = NSDecimalNumberHandler(roundingMode: .plain, scale: decimals, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let roundedNumber = rounding(accordingToBehavior: roundingBehaviour)
        
        Static.formatter.numberStyle = .currency
        
        if let currencyCode = currencyCode {
            Static.formatter.currencyCode = currencyCode
        }
        
        return Static.formatter.string(from: roundedNumber) ?? ""
    }
    
    func asRounded(_ decimals: Int16 = 2) -> NSDecimalNumber {
        let roundingBehaviour = NSDecimalNumberHandler(roundingMode: .plain, scale: decimals, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return rounding(accordingToBehavior: roundingBehaviour)
    }
    
    func asString(usesGrouping: Bool = true) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = usesGrouping
        
        return formatter.string(from: self) ?? ""
    }
    
    func asPosixString() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        return formatter.string(from: self) ?? ""
    }
}

// MARK: - Comparable
// From https://gist.github.com/mattt/1ed12090d7c89f36fd28

extension NSDecimalNumber: Comparable {}

public func == (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .orderedSame
}

public func < (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

// MARK: - Arithmetic Operators

public prefix func - (value: NSDecimalNumber) -> NSDecimalNumber {
    return value.multiplying(by: NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true))
}

public func + (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.adding(rhs)
}

public func += (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
    lhs = lhs.adding(rhs)
}

public func - (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.subtracting(rhs)
}

public func -= (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
    lhs = lhs.subtracting(rhs)
}

public func * (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.multiplying(by: rhs)
}

public func / (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.dividing(by: rhs)
}

public func ^ (lhs: NSDecimalNumber, rhs: Int) -> NSDecimalNumber {
    return lhs.raising(toPower: rhs)
}
