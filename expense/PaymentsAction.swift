//
//  PaymentsAction.swift
//  InVoice
//
//  Created by Georg Kitz on 04/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class NewPaymentAction: ProTapAction<AddItem> {
    override func performTap(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.addPayment.logEvent()
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let model = model as? PaymentsModel else {
            return
        }
        
        guard let nCtr = R.storyboard.payment.paymentNavigationViewController(), let root = nCtr.childViewControllers.first as? PaymentViewController else {
            return
        }
        
        root.invoice = model.invoice
        root.context = model.context
        
        ctr.present(nCtr, animated: true, completion: nil)
    }
}

class MarkAsPayedInFullAction: ProTapAction<AddItem> {
    override func performTap(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.markAsFullyPaid.logEvent()
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let model = model as? PaymentsModel else {
            return
        }
        
        model.markAsPayedInFull()
        ctr.navigationController?.popViewController(animated: true)
    }
}

class ShowPaymentAction: ProTapAction<PaymentItem> {
    override func performTap(with rowItem: PaymentItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.showPayment.logEvent()
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let model = model as? PaymentsModel else {
            return
        }
        
        guard let nCtr = R.storyboard.payment.paymentNavigationViewController(), let root = nCtr.childViewControllers.first as? PaymentViewController else {
            return
        }
        
        root.completionBlock = { _ in
            
        }
        root.payment = rowItem.value
        root.invoice = model.invoice
        root.context = model.context
        
        ctr.present(nCtr, animated: true, completion: nil)
    }
}
