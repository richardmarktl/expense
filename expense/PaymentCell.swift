//
//  PaymentCell.swift
//  InVoice
//
//  Created by Georg Kitz on 30/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

class PaymentCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = PaymentItem
    
    func configure(with item: PaymentItem) {
        textLabel?.text = item.title
        detailTextLabel?.text = item.amount
    }
}
