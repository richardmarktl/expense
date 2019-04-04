//
//  MailRecipient.swift
//  InVoice
//
//  Created by Georg Kitz on 27.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import TURecipientBar

class MailRecipient: NSObject, TURecipientProtocol {
    public var name: String?
    public var email: String
    
    public var recipientTitle: String {
        if let name = name {
            return name
        }
        return email
    }
    
    init(email: String, name: String?) {
        self.name = name
        self.email = email
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MailRecipient(email: email, name: name)
        return copy
    }
}
