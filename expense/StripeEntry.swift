//
//  StripeEntry.swift
//  InVoice
//
//  Created by Richard Marktl on 30.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

class StripeEntry: BoolItem {
    
    /// Inits the stripe invoice entry
    ///
    /// - Parameter invoice: Invoice
    convenience init(invoice: Invoice, isProFeature: Bool = false) {
        let defaultData = UITestHelper.isUITesting ? true : invoice.isStripeActivated
        self.init(title: R.string.localizable.stripe(), defaultData: defaultData)
        self.isProFeature = isProFeature
    }
}
