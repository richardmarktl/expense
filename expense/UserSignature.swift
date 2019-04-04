    //
//  UserSignature.swift
//  InVoice
//
//  Created by Richard Marktl on 28.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

class UserSignature: BoolItem {
    
    /// Inits the customer signature entry
    ///
    /// - Parameter invoice: Invoice
    convenience init(job: Job, isProFeature: Bool = false) {
        let defaultData: Bool = job.hasSignature
        self.init(title: UserSignature.title(date: job.signedOn), defaultData: defaultData)
        self.signed(on: job.signedOn)
        self.isProFeature = isProFeature
    }
    
    /// This methd will trigger an update of the title field.
    ///
    /// - Parameter date: used in the title
    func signed(on date: Date?) {
        title = UserSignature.title(date: date)
    }
    
    private static func title(date: Date?) -> String {
        if let date = date {
            return R.string.localizable.userSignedOn(date.asString())
        } else {
            return R.string.localizable.userSignature()
        }
    }
}
