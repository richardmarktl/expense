//
// Created by Richard Marktl on 2019-04-24.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import InvoiceBotSDK

class BudgetCategoryItem: BasicItem<BudgetCategory>  {
    private(set) var name: String = ""
    private(set) var description: String = ""

    init(defaultData: BudgetCategory) {
        super.init(defaultData: defaultData)
        update(with: defaultData)
    }

    func update(with entry: BudgetCategory) {
        name = entry.name ?? ""
        description = entry.categoryDescription ?? ""
        data.value = entry
    }
}
