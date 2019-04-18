//
// Created by Richard Marktl on 2019-04-11.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI

class SelectWalletAction: CollectionTapAction<WalletItem> {
    override func performTap(with rowItem: WalletItem, indexPath: IndexPath, sender: UICollectionView,
                             ctr: UIViewController, model: Model<UICollectionView>) {
        let nCtr = NewWalletViewController.show(item: rowItem.data.value)
        Analytics.walletSelect.logEvent()
        ctr.present(nCtr, animated: true)
    }
}