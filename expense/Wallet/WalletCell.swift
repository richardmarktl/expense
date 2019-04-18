//
//  WalletCell.swift
//  expense
//
//  Created by Richard Marktl on 04.04.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI

class WalletCell: ReusableCollectionViewCell, ConfigurableCell {
    typealias ConfigType = WalletItem

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    func configure(with item: WalletItem) {
        nameLabel.text = item.name
        typeLabel.text = item.type
    }
}
