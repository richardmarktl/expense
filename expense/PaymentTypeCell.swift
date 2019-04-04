//
//  PaymentTypeCell.swift
//  InVoice
//
//  Created by Georg Kitz on 30.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class PaymentTypeCell: PickerItemCell<PaymentType> {
    override func configure(with item: PickerItem<PaymentType>) {
        super.configure(with: item)
        proBadge.isHidden = true
    }
}
