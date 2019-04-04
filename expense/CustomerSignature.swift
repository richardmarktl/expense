//
//  CustomerSignature.swift
//  InVoice
//
//  Created by Richard Marktl on 28.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

class CustomerSignature: BoolItem {
    
    /// Inits the customer signature entry
    ///
    /// - Parameter invoice: Invoice
    convenience init(job: Job, isProFeature: Bool = false) {
        self.init(title: R.string.localizable.customerSignature(),  defaultData: job.needsSignature)
        self.isProFeature = isProFeature
    }
}
