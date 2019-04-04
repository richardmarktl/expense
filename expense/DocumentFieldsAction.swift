//
//  DocumentFieldsAction.swift
//  InVoice
//
//  Created by Georg Kitz on 09.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class ShowDocumentFieldsAction: TapActionable {
    typealias RowActionType = ActionItem
    
    func performTap(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        guard let languageSetCtr = R.storyboard.languageSet.instantiateInitialViewController() else {
            return
        }
        
        Analytics.themeShowDocumentPlaceholder.logEvent()
        
        languageSetCtr.context = model.context
        ctr.navigationController?.pushViewController(languageSetCtr, animated: true)
    }
    
    func rewindAction(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}
