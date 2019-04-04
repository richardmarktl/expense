//
//  Order+Sequence.swift
//  InVoice
//
//  Created by Georg Kitz on 27/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

class Tax {
    let percentageKey: String
    let percentage: NSDecimalNumber
    let tax: NSDecimalNumber
    let total: NSDecimalNumber
    
    init(percentageKey: String, percentage: NSDecimalNumber, tax: NSDecimalNumber, total: NSDecimalNumber) {
        self.percentageKey = percentageKey
        self.percentage = percentage
        self.tax = tax
        self.total = total
    }
}

extension Sequence where Iterator.Element: Order {
    
    func subtotal(with discount: NSDecimalNumber = NSDecimalNumber.zero) -> NSDecimalNumber {
        return reduce(NSDecimalNumber.zero) { (result, order) -> NSDecimalNumber in
            var total = order.total ?? NSDecimalNumber.zero
            if discount != NSDecimalNumber.zero {
                total = total * (1 - discount / 100)
            }
            return result + total
        }
    }
    
    func vats(with discount: NSDecimalNumber = NSDecimalNumber.zero) -> [Tax] {
        return map({ (order) -> Tax in
            var total = order.total ?? NSDecimalNumber.zero
            if discount != NSDecimalNumber.zero {
                total = total * (1 - discount / 100)
            }
            let percentage = order.tax ?? NSDecimalNumber.zero
            let tax = total * (percentage / 100)
            return Tax(percentageKey: percentage.asString(), percentage: percentage, tax: tax, total: total)
        })
    }
}

extension Sequence where Iterator.Element: Tax {
    
    var tax: NSDecimalNumber {
        return reduce(NSDecimalNumber.zero, { (result, tax) -> NSDecimalNumber in
            return result + tax.tax
        })
    }
    
    var total: NSDecimalNumber {
        return reduce(NSDecimalNumber.zero, { (result, tax) -> NSDecimalNumber in
            return result + tax.total
        })
    }
    
    var vatToTotal: [String: NSDecimalNumber] {
        return Dictionary(grouping: self) { $0.percentageKey }.mapValues({ (taxes) -> NSDecimalNumber in
            return taxes.total
        })
    }
    
    var vatToTax: [String: NSDecimalNumber] {
        return Dictionary(grouping: self) { $0.percentageKey }.mapValues({ (taxes) -> NSDecimalNumber in
            return taxes.tax
        })
    }
}

extension NSDecimalNumber {
    func considerDiscount(_ discount: NSDecimalNumber) -> NSDecimalNumber {
        return self * (1 - discount / 100)
    }
}
