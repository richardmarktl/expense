//
// Created by Richard Marktl on 2019-04-18.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CommonUI

class BudgetEntryCell: ReusableCollectionViewCell, ConfigurableCell {
    typealias ConfigType = BudgetEntryItem

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    func configure(with item: BudgetEntryItem) {
        nameLabel.text = item.name
        typeLabel.text = item.type
    }
}
