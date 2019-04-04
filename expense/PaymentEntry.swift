//
//  PaymentItem.swift
//  InVoice
//
//  Created by Georg Kitz on 01/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - Convenience init for the description
extension TextEntry {
    convenience init(payment: Payment?) {
        let description = payment?.note ?? ""
        self.init(placeholder: R.string.localizable.description(), value: description, autoCapitalizationType: UITextAutocapitalizationType.sentences)
    }
}

extension NumberEntry {
    convenience init(payment: Payment?) {
        let amount = payment?.amount ?? NSDecimalNumber.zero
        self.init(title: R.string.localizable.amount(), defaultData: amount)
    }
}

extension DateItem {
    convenience init(payment: Payment?) {
        let date = payment?.paymentDate ?? Date()
        self.init(title: R.string.localizable.date(), defaultData: date)
    }
}

extension PaymentType: PickerItemInterface {
    
    var shortDesignName: String {
        return asLocalizedString
    }
    
    var longName: String {
        return asLocalizedString
    }
    
    var displayName: String {
        return asLocalizedString
    }
    
    var hint: String? {
        return nil
    }
    
    static func create(from paymentType: String) -> PaymentType {
        if let value = PaymentType(rawValue: paymentType) {
            return value
        }
        return .cash
    }
    
    static var all: [PaymentType] {
        return [.cash, .check, .bankTransfer, .creditCard, .payPal, .online, .other]
    }
}

class PaymentTypeEntry: PickerItem<PaymentType> {
    convenience init(payment: Payment?) {
        let method = payment?.paymentType ?? .cash
        self.init(title: R.string.localizable.method(), defaultData: method)
    }
}
