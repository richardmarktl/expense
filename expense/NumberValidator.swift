//
//  NumberValidator.swift
//  InVoice
//
//  Created by Georg Kitz on 7/23/18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
class NumberValidator: NSObject, UITextFieldDelegate {

    private struct Static {
        static let regex = "^\\d{1,2}(\\\(NumberFormatter().decimalSeparator!)\\d{0,2})?$"
    }
    private let formatter: NumberFormatter = NumberFormatter()

    enum ValidatorType {
        case `default`
        case tax
        case boundaries(Int32, Int32)

        func validate(replacementString: String, number: NSNumber) -> Bool {
            switch self {
            case .tax:
                return replacementString.range(of: Static.regex, options: .regularExpression) != nil
            case .boundaries(let min, let max):
                return number.intValue > min && number.intValue < max
            case .default:
                return true
            }
        }
    }

    var validatorType: ValidatorType = .default

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }

        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)

        guard let number = formatter.number(from: replacementText) else {
            return false
        }

        return validatorType.validate(replacementString: replacementText, number: number)
    }
}
