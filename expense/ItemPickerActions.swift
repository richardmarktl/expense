//
//  ItemAction.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import ContactsUI

class ItemItem: BasicItem<Item> {
    let price: String
    init(item: Item) {
        
        price = item.price?.asCurrency(currencyCode: nil) ?? ""
        
        let title = item.title ?? ""
        super.init(title: title, defaultData: item)
    }
}

// MARK: - Parent Action
class ItemSelectAction {
    
    /// completes picking an order, calls completion handler and dismisses the controller
    ///
    /// - Parameters:
    ///   - order: the order we picked
    ///   - controller: the controller we want to use to call the completion handler on
    func complete(with order: Order, in controller: UIViewController) {
        guard let pickerController = controller as? ItemPickerViewController, let completion = pickerController.completionBlock else {
            return
        }
        
        completion(order)
    }
    
    /// Shows the controller and prefills the item if we have one
    ///
    /// - Parameter item: item we want to prefill the controller with
    fileprivate func showController(with item: Item? = nil, presentOn ctr: UIViewController, model: TableModel) {
        
        guard let model = model as? ItemPickerModel else {
            return
        }
        
        let order = Order.create(in: model.context)
        if let item = item {
            order.update(from: item)
        }
        
        let completion: ((Order) -> Void) = { [unowned self] order in
            order.update(job: model.job)
            self.complete(with: order, in: ctr)
        }
        
        let nCtr = OrderViewController.show(item: order, in: model.context, completionBlock: completion)
        guard let picker = nCtr.childViewControllers.first as? OrderViewController else {
            return
        }
        
        picker.dismissActionBlock = { root in
            ctr.presentingViewController?.dismiss(animated: true)
        }
        ctr.present(nCtr, animated: true)
    }
}

// MARK: - NewOrderAction
class NewOrderAction: ItemSelectAction, TapActionable {
    typealias RowActionType = AddItem
    
    func performTap(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        Analytics.addInvoiceNewOrder.logEvent()
        showController(presentOn: ctr, model: model)
    }
    
    func rewindAction(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}

// MARK: - Picks one of the stored items and prefills the order controller with it
class PickItemAction: ItemSelectAction, TapActionable {
    typealias RowActionType = ItemItem
    
    func performTap(with rowItem: ItemItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        Analytics.addInvoicePickItem.logEvent()
        showController(with: rowItem.data.value, presentOn: ctr, model: model)
    }
    
    func rewindAction(with rowItem: ItemItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}
