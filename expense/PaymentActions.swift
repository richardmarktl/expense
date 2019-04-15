//
//  PaymentActions.swift
//  InVoice
//
//  Created by Richard Marktl on 12.04.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class NoOperationBoolAction: TapActionable {
    typealias RowActionType = BoolItem
    func performTap(with rowItem: BoolItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
    
    }
    
    func rewindAction(with rowItem: BoolItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}
