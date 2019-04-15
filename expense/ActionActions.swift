//
//  ActionActions.swift
//  InVoice
//
//  Created by Georg Kitz on 26/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import Crashlytics

class PreviewAction: TapActionable {
    typealias RowActionType = ActionItem
    func performTap(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        guard let model = model as? JobModel,
            let pCtr: GeneratedPreviewController = R.storyboard.preview.instantiateInitialViewController() else {
            return 
        }
        
        // show an reset dialog in the case the use has send it already
        Analytics.actionShowPreview.logEvent()
        model.updateJobForSaving()
        
        pCtr.job = model.job
        pCtr.renderer = model.renderer
        pCtr.hideSendButton = model.job.remoteId == DefaultData.TestRemoteID
        ctr.navigationController?.pushViewController(pCtr, animated: true)
    }
    
    func rewindAction(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}

class SendAction: ProTapAction<ActionItem> {
    override func performTap(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }

        guard let ctr = ctr as? JobViewController, let model = model as? JobModel, let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        model.updateJobForSaving()
        _ = model.renderer.pdfObservable.take(1).subscribe(onNext: { (pdf) in
            ctr.presentSendPicker(for: model.job, with: pdf, from: cell, completion: {
                tableView.deselectRow(at: indexPath, animated: true)
            })
        })
    }
    
    func canPerformTap(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) -> Bool {
        return rowItem.isEnabled
    }
}

class ShareJobAction: ProTapAction<ActionItem> {
    override func performTap(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let ctr = ctr as? JobViewController, let model = model as? JobModel, let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        model.updateJobForSaving()
        _ = model.renderer.pdfObservable.take(1).subscribe(onNext: { (pdf) in
            ctr.presentShareSheet(for: model.job, with: pdf, from: cell)
        })
        
        tableView.deselectRow(at: indexPath, animated: true)        
    }
}

class DuplicateAction: ProTapAction<ActionItem> {
    override func performTap(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let model = model as? JobModel else {
            return
        }
        
        let checkerType = model.job is Invoice ? LimitChecker.LimitType.invoice : LimitChecker.LimitType.offer
        if !LimitChecker.isWithingLimits(for: checkerType) {
            let message = R.string.localizable.limitReached(model.job.localizedType)
            ctr.showUpsellAlert(message: message)
            return
        }
        
        let job = model.duplicate()
        
        DispatchQueue.main.async {
            let type = job.localizedType
            let message = R.string.localizable.invoiceCreated(type, job.number ?? "")
            let alert = UIAlertController(title: R.string.localizable.information(), message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: R.string.localizable.oK(), style: .cancel, handler: nil)
            alert.addAction(okAction)
            ctr.present(alert, animated: true)
        }
        
        let type = job is Invoice ? "invoice" : "offer"
        Analytics.actionDuplicate.logEvent(["source": type.asNSString])
    }
}

class ConvertToInvoiceAction: ProTapAction<ActionItem> {
    override func performTap(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let model = model as? JobModel else {
            return
        }
        
        let invoice = model.createInvoiceFromOffer()
        
        model.actionSection.reloadData()
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        DispatchQueue.main.async {
            let type = invoice.localizedType
            let message = R.string.localizable.invoiceCreated(type, invoice.number ?? "")
            let alert = UIAlertController(title: R.string.localizable.information(), message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: R.string.localizable.oK(), style: .cancel, handler: nil)
            alert.addAction(okAction)
            ctr.present(alert, animated: true)
        }
        
        Analytics.actionOfferToInvoice.logEvent()
    }
}

class PaymentsAction: TapActionable {
    typealias RowActionType = ActionItem
    func performTap(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.showPayments.logEvent()
        
        guard let model = model as? JobModel, let invoice = model.job as? Invoice else {
            return
        }
        
        guard let pCtr = R.storyboard.payment().instantiateInitialViewController() as? PaymentsViewController else {
                return
        }
        
        pCtr.invoice = invoice
        pCtr.context = model.context
        
        ctr.navigationController?.pushViewController(pCtr, animated: true)
    }
    
    func rewindAction(with rowItem: ActionItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}
