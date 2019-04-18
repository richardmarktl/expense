//
//  NewWalletViewController.swift
//  expense
//
//  Created by Richard Marktl on 09.04.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import InvoiceBotSDK
import CommonUI

class NewWalletViewController: DetailTableModelController<BudgetWallet, WalletModel> {
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.textFieldCell)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,
                action: #selector(done))
    }

    override class func controllers<T>(type: T.Type) -> (UINavigationController, T) {
        guard let nCtr = R.storyboard.wallet.newWalletRootViewController(), let ctr = nCtr.children.first as? T else {
            fatalError()
        }
        return (nCtr, ctr)
    }

    @objc func done() {
        self.dismiss(animated: true)
    }
}
