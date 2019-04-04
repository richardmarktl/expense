//
//  PayPalEntry.swift
//  InVoice
//
//  Created by Richard Marktl on 12.04.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

class PayPalEntry: BoolItem {
    
    /// Inits the paypal invoice entry
    ///
    /// - Parameter invoice: Invoice
    convenience init(invoice: Invoice, isProFeature: Bool = false) {
        let defaultData = UITestHelper.isUITesting ? true : invoice.isPayPalActivated
        self.init(title: R.string.localizable.paypal(), defaultData: defaultData)
        self.isProFeature = isProFeature
    }
}
