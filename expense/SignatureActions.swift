//
// Created by Richard Marktl on 14.09.18.
// Copyright (c) 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit

class RecipientAction: TapActionable {
    typealias RowActionType = RecipientItem

    func performTap(with rowItem: RecipientItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        if rowItem.value.typedState == .signed, let sCtr = R.storyboard.recipient().instantiateInitialViewController() as? RecipientViewController {
            Analytics.showSignature.logEvent()
            
            sCtr.recipient = rowItem.value
            ctr.navigationController?.pushViewController(sCtr, animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func rewindAction(with rowItem: RecipientItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {

    }
}
