//
//  PhoneNumberValidator.swift
//  InVoice
//
//  Created by Georg Kitz on 24.11.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

struct PhoneNumberValidator {
    
    private static let phoneNumberRegex = "^((\\+)|(00)|(0))[0-9\\s]{6,14}$"
    private static let phoneNumberPredicate: NSPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
    
    static func validate(phoneNumber: String) -> Bool {
        return phoneNumberPredicate.evaluate(with: phoneNumber)
    }
}
