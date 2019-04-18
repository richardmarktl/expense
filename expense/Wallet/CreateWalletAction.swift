//
// Created by Richard Marktl on 2019-04-11.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import CommonUI

class CreateWalletAction: CollectionTapAction<ActionItem> {
    override func performTap(with rowItem: ActionItem, indexPath: IndexPath, sender: UICollectionView, ctr: UIViewController, model: Model<UICollectionView>) {
        super.performTap(with: rowItem, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
        let nCtr = NewWalletViewController.createItem()
        Analytics.walletNew.logEvent()
        ctr.present(nCtr, animated: true)
    }

    override func rewindAction(with rowItem: ActionItem, indexPath: IndexPath, sender: UICollectionView, ctr: UIViewController, model: Model<UICollectionView>) {
        super.rewindAction(with: rowItem, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }
}