//
//  WalletViewController.swift
//  expense
//
//  Created by Richard Marktl on 04.04.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData


class WalletViewController: CollectionModelController<WalletModel> {
    override func viewDidLoad() {
        super.viewDidLoad()

        // tableView
        collectionView.register(R.nib.createWalletCell)
        collectionView.register(R.nib.walletCell)
    }
}
