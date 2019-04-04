//
//  ItemCell.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell, ConfigurableCell {
    
    typealias ConfigType = ItemItem
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configure(with item: ItemItem) {
        titleLabel?.text = item.title.sampleHintReplaced
        priceLabel?.text = item.price
    }
}
