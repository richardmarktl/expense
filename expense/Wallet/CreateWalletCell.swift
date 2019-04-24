//
// Created by Richard Marktl on 2019-04-10.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI

class CreateWalletCell: ReusableCollectionViewCell, ConfigurableCell {
    typealias ConfigType = ActionItem
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with item: ConfigType) {
        titleLabel.text = item.title
    }
}
