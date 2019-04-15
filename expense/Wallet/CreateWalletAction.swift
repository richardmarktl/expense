//
// Created by Richard Marktl on 2019-04-11.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit

class CreateWalletAction: CollectionTapAction<ActionItem> {
    func performTap(with rowItem: WalletItem, indexPath: IndexPath, sender: UICollectionView, ctr: UIViewController, model: TableModel) {
        let nCtr = NewWalletViewController.createWallet()
        // Analytics.itemNew.logEvent() FIXME: please add a create wallet event.
        ctr.present(nCtr, animated: true)
    }
}