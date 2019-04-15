//
//  ItemActions.swift
//  InVoice
//
//  Created by Georg Kitz on 22/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum

class AddItemAction: ProTapAction<AddItem> {
    override func performTap(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let model = model as? JobModel else {
            return
        }
        
        let completionBlock: ((Order) -> Void) = { order in
            
            order.update(job: model.job)
            
            tableView.beginUpdates()
            
            model.itemSection.add(order: order, at: indexPath)
            
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
        }
        
        if Item.allObjects(matchingPredicate: NSPredicate.undeletedItem(), fetchLimit: 1, context: model.context).count == 0 {
            
            guard let nCtr = R.storyboard.itemSearch.orderNavigationViewController(), let picker = nCtr.childViewControllers.first as? OrderViewController else {
                return
            }
            
            let item = Order.create(in: model.context)
            picker.cancelBlock = { [weak item] in
                guard let item = item else { return }
                item.managedObjectContext?.delete(item)
            }
            picker.item = item
            picker.context = model.context
            picker.completionBlock = completionBlock
            ctr.present(nCtr, animated: true)
            
        } else {
            
            guard let nCtr = R.storyboard.itemSearch().instantiateInitialViewController() as? UINavigationController, let picker = nCtr.childViewControllers.first as? ItemPickerViewController else {
                return
            }
            
            picker.job = model.job
            picker.context = model.context
            picker.completionBlock = completionBlock
            Analytics.addInvoicePickerItem.logEvent()
            ctr.present(nCtr, animated: true)
        }
    }
}

class OrderItemAction: ProTapAction<OrderItem> {
    override func performTap(with rowItem: OrderItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let model = model as? JobModel else {
            return
        }

        let completion = { (order: Order) in
            
            order.update(job: model.job)
            
            model.itemSection.update(order: order, at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let remove = {
            
            model.itemSection.remove(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        Analytics.addInvoiceSelectOrder.logEvent()
        
        let nCtr = OrderViewController.show(item: rowItem.value, in: model.context, completionBlock: completion, removeBlock: remove)
        ctr.present(nCtr, animated: true)
    }
}
