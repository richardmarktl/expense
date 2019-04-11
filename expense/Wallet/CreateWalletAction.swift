//
// Created by Richard Marktl on 2019-04-11.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation

class CreateWalletAction: TapAction<WalletItem> {
    override func performTap(with rowItem: WalletItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {

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