//
//  OrderItemCell.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class OrderItemCell: ReusableCell, ConfigurableCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    typealias ConfigType = OrderItem
    
    func configure(with item: OrderItem) {
        titleLabel.text = item.itemName
        detailTitleLabel.text = item.itemDetails
        priceLabel.text = item.itemTotal
    }
}
