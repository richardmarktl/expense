//
//  CompanyViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData
import Horreum

class AccountViewController: DetailTableModelController<Account, AccountModel> {
    
    override class func controllers<T>(type: T.Type) -> (UINavigationController, T) {
        guard let nCtr = R.storyboard.clients.accountViewRootController(), let ctr = nCtr.childViewControllers.first as? T else {
            fatalError()
        }
        return (nCtr, ctr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.textViewCell)
        tableView.register(R.nib.textFieldCell)
        deleteButton?.isHidden = true
    }
}
