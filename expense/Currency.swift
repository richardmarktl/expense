//
//  Currency.swift
//  InVoice
//
//  Created by Georg Kitz on 29.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

struct Currency: Decodable {
    
    let symbol: String
    let name: String
    let symbolNative: String
    let decimalDigits: Int
    let rounding: Decimal
    let code: String
    let namePlural: String
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case name
        case symbolNative = "symbol_native"
        case decimalDigits = "decimal_digits"
        case rounding
        case code
        case namePlural = "name_plural"
    }
}

extension Currency: PickerItemInterface {
    var shortDesignName: String {
        return symbolNative
    }
    
    var longName: String {
        return name
    }
    
    var displayName: String {
        return code + " - " + name
    }
    
    var hint: String? {
        return R.string.localizable.currencySelectorHint()
    }
    
    static var all: [Currency] {
        return CurrencyLoader.allCurrencies
    }
    
    static func create(from rawValue: String) -> Currency {
        let currentCurrency = all.lazy.filter { $0.code == rawValue }.first
        if let currentCurrency = currentCurrency {
            return currentCurrency
        }
        return create(from: "EUR")
    }
}

// please remove once 4.2 is released, since this is done automatically
extension Currency: Equatable {
}

func ==(lhs: Currency, rhs: Currency) -> Bool {
    let areEqual =
    lhs.symbol == rhs.symbol &&
    lhs.name == rhs.name &&
    lhs.symbolNative == rhs.symbolNative &&
    lhs.decimalDigits == rhs.decimalDigits &&
    lhs.rounding == rhs.rounding &&
    lhs.code == rhs.code &&
    lhs.namePlural == rhs.namePlural
    
    return areEqual
}
