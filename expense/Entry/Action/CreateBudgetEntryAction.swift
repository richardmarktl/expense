//
// Created by Richard Marktl on 2019-04-23.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI

class CreateBudgetEntryAction: CollectionTapAction<ActionItem> {
    override func performTap(with rowItem: ActionItem, indexPath: IndexPath, sender: UICollectionView,
                             ctr: UIViewController, model: Model<UICollectionView>) {

        // TODO: add Analytics
        guard let parent = ctr as? BudgetEntriesViewController, let wallet = parent.wallet else {
            fatalError("Not able to cast the BudgetEntriesViewController")
        }

        ctr.navigationController?.pushViewController(EditBudgetEntryViewController.newEntry(with: wallet), animated: true)
    }
}