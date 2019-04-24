//
// Created by Richard Marktl on 2019-04-18.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CommonUI

class SelectBudgetEntryAction: CollectionTapAction<BudgetEntryItem> {
    override func performTap(with rowItem: BudgetEntryItem, indexPath: IndexPath, sender: UICollectionView,
                             ctr: UIViewController, model: Model<UICollectionView>) {
        let editCtr = EditBudgetEntryViewController.edit(entry: rowItem.value)
        ctr.navigationController?.pushViewController(editCtr, animated: true)
    }
}