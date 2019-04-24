//
// Created by Richard Marktl on 2019-04-24.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI

class BudgetEntrySelectCategoryCell: ReusableTableViewCell, ConfigurableCell {
    typealias ConfigType = BudgetEntryItem

    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var categoryName: UILabel!

    func configure(with item: BudgetEntryItem) {
        if let category = item.value.category {
            categoryIcon.image = nil
            categoryName.text = category.name
        } else {
            categoryName.text = R.string.localizable.noCategory()
            categoryIcon.image = R.image.add_item()
        }
    }
}

