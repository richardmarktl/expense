//
//  ClientViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 17/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData
import Horreum

class ClientViewController: DetailTableModelController<Client, ClientModel> {
    
    override class func controllers<T>(type: T.Type) -> (UINavigationController, T) {
        guard let nCtr = R.storyboard.clients.clientViewRootController(), let ctr = nCtr.childViewControllers.first as? T else {
            fatalError()
        }
        return (nCtr, ctr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(R.nib.textViewCell)
        tableView.register(R.nib.textFieldCell)
        
        deleteButton?.title = model.deleteButtonTitle
        askBeforeDeletion = model.storeChangesAutomatically
    }
}
