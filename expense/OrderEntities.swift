//
//  OrderEntities.swift
//  InVoice
//
//  Created by Georg Kitz on 22/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit

/// Represents the data in the NumberCell
class NumberEntry: BasicItem<NSDecimalNumber> {
    
    let keyboardType: UIKeyboardType
    let validatorType: NumberValidator.ValidatorType
    
    var textValue: String {
        return value.asString(usesGrouping: false)
    }
    
    func update(with stringValue: String) {
        data.value = NSDecimalNumber(string: stringValue, locale: Locale.current)
    }
    
    /// Inits the quantity
    ///
    /// - Parameter order: uses the quantity of the order or 1
    convenience init(quantityOf order: Order?) {
        let quantity = order?.quantity ?? NSDecimalNumber(value: 1)
        self.init(title: R.string.localizable.quantity(), defaultData: quantity)
    }
    
    /// Inits the tax
    ///
    /// - Parameters:
    ///   - order: takes the tax of the order
    ///   - item: takes the tax of the template item or zero
    convenience init(taxOf order: Order?, item: Item?) {
        
        let defaultTax = Account.current().tax ?? NSDecimalNumber.zero
        var tax = NSDecimalNumber.zero
        
        if let order = order {
            tax = order.tax ?? (order.isInserted ? defaultTax : NSDecimalNumber.zero)
        } else if let item = item {
            tax = item.tax ?? (item.isInserted ? defaultTax : NSDecimalNumber.zero)
        }
        
        self.init(title: R.string.localizable.tax(), defaultData: tax, validatorType: .tax)
    }
    
    /// Inits the price
    ///
    /// - Parameters:
    ///   - order: takes the price of the order
    ///   - item: or the template item, or zero if both are nil
    convenience init(priceOf order: Order?, item: Item?) {
        let currency = CurrencyLoader.currentCurrency.symbolNative
        let price = order?.price ?? (item?.price ?? NSDecimalNumber.zero)
        self.init(title: R.string.localizable.price(currency), defaultData: price)
    }
    
    init(title: String, defaultData: NSDecimalNumber, validatorType: NumberValidator.ValidatorType = .default, keyboardType: UIKeyboardType = .decimalPad) {
        self.validatorType = validatorType
        self.keyboardType = keyboardType
        super.init(title: title, defaultData: defaultData)
    }
}

/// Wraps the discount
typealias Discount = (value: NSDecimalNumber, isAbsolute: Bool)
class DiscountEntry: BasicItem<Discount> {
    
    var textValue: String {
        return value.value.asString()
    }
    
    func update(with stringValue: String) {
        var discount = value
        
        let formatter = NumberFormatter()
        let newValue: NSDecimalNumber
        if let number = formatter.number(from: stringValue) {
            newValue = NSDecimalNumber(decimal: number.decimalValue)
        } else {
            newValue = NSDecimalNumber.zero
        }
        discount.value = newValue
        data.value = discount
    }
    
    func update(with isAbsolute: Bool) {
        var discount = value
        discount.isAbsolute = isAbsolute
        data.value = discount
        
        let currency = CurrencyLoader.currentCurrency.symbolNative
        let type = isAbsolute ? currency : "%"
        title = R.string.localizable.discount(type)
    }
    
    convenience init(discountable: Discountable?) {
        let discountValue = discountable?.discount ?? (NSDecimalNumber.zero)
        let isAbsoluteValue = discountable?.isDiscountAbsolute ?? true
        let discount = (value: discountValue, isAbsolute: isAbsoluteValue)
        
        let currency = CurrencyLoader.currentCurrency.symbolNative
        let type = isAbsoluteValue ? currency : "%"
        self.init(title: R.string.localizable.discount(type), defaultData: discount)
    }
}

// MARK: - Protocol to generalize the discount properties
protocol Discountable {
    var discount: NSDecimalNumber? {get}
    var isDiscountAbsolute: Bool {get}
}

extension Order: Discountable {}
extension Job: Discountable {}

// MARK: - Convenience init for the description
extension TextEntry {
    convenience init(descriptionForOrder order: Order?, orItem item: Item?) {
        let description = order?.itemDescription ?? item?.itemDescription
        self.init(placeholder: R.string.localizable.description(), value: description, autoCapitalizationType: UITextAutocapitalizationType.words)
    }
    
    convenience init(titleForOrder order: Order?, orItem item: Item?) {
        let title = order?.title ?? item?.title
        self.init(placeholder: R.string.localizable.title(), value: title, autoCapitalizationType: UITextAutocapitalizationType.words)
    }
    
    convenience init(numberForOrder order: Order?, orItem item: Item?) {
        let title = order?.number ?? item?.number
        self.init(placeholder: "number", value: title, autoCapitalizationType: UITextAutocapitalizationType.allCharacters)
    }
}
