//
//  DefaultValidators.swift
//  InVoice
//
//  Created by Georg Kitz on 13.03.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import EmailValidator

struct DefaultValidators {
    
    static let phoneValidator: StringValidator = { phone -> Bool in
        let phoneNumber = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        return phone.isEmpty || PhoneNumberValidator.validate(phoneNumber: phoneNumber)
    }
    
    static let emailValidator: StringValidator =  { email -> Bool in
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return email.isEmpty || EmailValidator.validate(email: trimmedEmail, allowTopLevelDomains: false, allowInternational: true)
    }
    
    static let websiteValidator: StringValidator = { website -> Bool in
        let trimmedWebsite = website.trimmingCharacters(in: .whitespacesAndNewlines)
        return website.isEmpty || UrlValidator.validate(urlString: trimmedWebsite)
    }
}
