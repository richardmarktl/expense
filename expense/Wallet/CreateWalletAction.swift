//
// Created by Richard Marktl on 2019-04-11.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit

class CreateWalletAction: CollectionTapAction<ActionItem> {
//    override func canPerformTap(with rowItem: ActionItem, indexPath: IndexPath, sender: UICollectionView, ctr: UIViewController, model: TableModel<UICollectionView>) -> Bool {
//        return super.canPerformTap(with: rowItem, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
//    }

    override func performTap(with rowItem: ActionItem, indexPath: IndexPath, sender: UICollectionView, ctr: UIViewController, model: TableModel<UICollectionView>) {
        super.performTap(with: rowItem, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
        let nCtr = NewWalletViewController.createWallet()
        // Analytics.itemNew.logEvent() FIXME: please add a create wallet event.
        ctr.present(nCtr, animated: true)
    }

    override func rewindAction(with rowItem: ActionItem, indexPath: IndexPath, sender: UICollectionView, ctr: UIViewController, model: TableModel<UICollectionView>) {
        super.rewindAction(with: rowItem, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }
}