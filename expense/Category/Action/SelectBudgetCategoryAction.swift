//
// Created by Richard Marktl on 2019-04-24.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI
import InvoiceBotSDK

class SelectBudgetCategoryAction: CollectionTapAction<BudgetCategoryItem> {
    override func performTap(with rowItem: BudgetCategoryItem, indexPath: IndexPath, sender: UICollectionView,
                             ctr: UIViewController, model: Model<UICollectionView>) {
        // if the entry property is set, add the entry to selected category and dismiss the
        // BudgetCategoriesViewController controller, otherwise open the edit view.
        // TODO: Analytics
        if let entry = (ctr as? BudgetCategoriesViewController)?.entry {
            entry.category = rowItem.value
            ctr.dismiss(animated: true)
        } else {
            let categoryCtr = BudgetCategoryEditViewController.edit(category: rowItem.value)
            ctr.navigationController?.pushViewController(categoryCtr, animated: true)
        }
    }
}
