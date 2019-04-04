//
//  ItemViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 18/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreData
import Horreum

class ItemViewController: DetailTableModelController<Item, ItemModel> {
    override class func controllers<T>(type: T.Type) -> (UINavigationController, T) {
        guard let nCtr = R.storyboard.items.itemViewRootController(), let ctr = nCtr.childViewControllers.first as? T else {
            fatalError()
        }
        return (nCtr, ctr)
    }
}
