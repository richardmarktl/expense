//
// Created by Richard Marktl on 2019-04-11.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI

class SelectWalletAction: CollectionTapAction<WalletItem> {
    override func performTap(with rowItem: WalletItem, indexPath: IndexPath, sender: UICollectionView,
                             ctr: UIViewController, model: Model<UICollectionView>) {
        guard let nCtr = R.storyboard.wallet.budgetEntriesController(),
              let entriesCtr = nCtr.children.first as? BudgetEntriesViewController else {
            fatalError("An error occurred during the creation of BudgetEntriesViewController.")
        }
        Analytics.walletSelect.logEvent()
        entriesCtr.wallet = rowItem.value
        ctr.present(nCtr, animated: true)
    }
}