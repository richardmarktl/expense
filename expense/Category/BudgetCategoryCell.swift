//
// Created by Richard Marktl on 2019-04-24.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI

class BudgetCategoryCell: ReusableCollectionViewCell, ConfigurableCell {
    typealias ConfigType = BudgetCategoryItem

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func configure(with item: BudgetCategoryItem) {
        nameLabel.text = item.name
        descriptionLabel.text = item.description
    }
}