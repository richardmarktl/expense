//
// Created by Richard Marktl on 2019-04-24.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI
import InvoiceBotSDK

class CreateBudgetCategoryAction: CollectionTapAction<ActionItem> {
    override func performTap(with rowItem: ActionItem, indexPath: IndexPath, sender: UICollectionView,
                             ctr: UIViewController, model: Model<UICollectionView>) {

        // TODO: add Analytics
        let entry: BudgetEntry? = (ctr as? BudgetCategoriesViewController)?.entry
        let categoryCtr = BudgetCategoryEditViewController.newCategory(with: entry)
        ctr.navigationController?.pushViewController(categoryCtr, animated: true)
    }
}
