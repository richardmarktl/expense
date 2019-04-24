//
// Created by Richard Marktl on 2019-04-24.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI

class SelectBudgetCategoryForEntryAction: TapAction<BudgetEntryItem> {
    override func performTap(with rowItem: BudgetEntryItem, indexPath: IndexPath, sender: UITableView,
                             ctr: UIViewController, model: Model<UITableView>) {

        guard let nCtr = R.storyboard.category.budgetCategoriesViewController(),
              let categoryCtr = nCtr.children.first as? BudgetCategoriesViewController else {
            fatalError("An error occurred during the creation of BudgetCategoriesViewController.")
        }

        Analytics.categorySelect.logEvent()
        categoryCtr.entry = rowItem.value
        ctr.present(nCtr, animated: true)
    }
}
