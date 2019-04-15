//
//  ClientActions.swift
//  InVoice
//
//  Created by Georg Kitz on 22/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class AddClientAction: ProTapAction<AddItem> {
    
    override func performTap(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let nCtr = R.storyboard.clientSearch().instantiateInitialViewController() as? UINavigationController,
            let picker = nCtr.childViewControllers.first as? ClientPickerViewController, let model = model as? JobModel else {
            return
        }
        
        picker.context = model.context
        picker.completionBlock = { client in
            
            model.clientSection.update(with: client)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        Analytics.addInvoicePickerClient.logEvent()
        ctr.present(nCtr, animated: true)
    }
}

class ClientAction: ProTapAction<ClientItem> {
    override func performTap(with rowItem: ClientItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let model = model as? JobModel else {
            return
        }
        
        let completionBlock = { (client: Client) in
            model.clientSection.update(with: client)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let removeBlock = {
            model.clientSection.removeClient()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        Analytics.addInvoiceSelectClient.logEvent()
        let nCtr = ClientViewController.show(item: rowItem.value, in: model.context, completionBlock: completionBlock, removeBlock: removeBlock)
        ctr.present(nCtr, animated: true)
    }
}
