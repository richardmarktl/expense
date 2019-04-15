//
// Created by Richard Marktl on 2019-04-11.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit

class SelectWalletAction: CollectionTapAction<WalletItem> {
    override func performTap(with rowItem: WalletItem, indexPath: IndexPath, sender: UICollectionView, ctr: UIViewController, model: TableModel<UICollectionView>) {

//        if isProExpired {
//            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
//            return
//        }
        print("did select wallet")
        //this ensures that the client is loaded in a childcontext to allow changes
        // TODO: add an controller to list the entries.
//        let nCtr =  ClientViewController.show(item: rowItem.item)
//        Analytics.clientSelect.logEvent()
//        ctr.present(nCtr, animated: true)
    }
}