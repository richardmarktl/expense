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
//import MessageUI
//import SwiftReorder


class NewWalletViewController: DetailTableModelController<Wallet, WalletModel> {
    override class func controllers<T>(type: T.Type) -> (UINavigationController, T) {
        guard let nCtr = R.storyboard.wallet.newWalletRootViewController(), let ctr = nCtr.children.first as? T else {
            fatalError()
        }
        return (nCtr, ctr)
    }
}
