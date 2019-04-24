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

    init(title: String, defaultData: NSDecimalNumber, validatorType: NumberValidator.ValidatorType = .default, keyboardType: UIKeyboardType = .decimalPad) {
        self.validatorType = validatorType
        self.keyboardType = keyboardType
        super.init(title: title, defaultData: defaultData)
    }
}
