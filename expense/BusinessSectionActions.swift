//
//  BusinessSectionActions.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class SettingsBusinessDetailsAction: ProTapAction<SettingsItem> {
    
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        let account = Account.allObjects(context: model.context).first!
        let nCtr = AccountViewController.show(item: account)
        Analytics.settingsBusiness.logEvent()
        ctr.present(nCtr, animated: true)
    }
}

class SettingsTaxAction: ProTapAction<SettingsItem> {
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        Analytics.settingsTax.logEvent()
        let tax = Account.allObjects(context: model.context).first!
        let nCtr = TaxController.show(item: tax)
        ctr.present(nCtr, animated: true)
    }
}

class SettingsPaymentDetailAction: ProTapAction<SettingsItem> {
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        let tax = Account.allObjects(context: model.context).first!
        let nCtr = PaymentDetailsController.show(item: tax)
        Analytics.settingsPayment.logEvent()
        ctr.present(nCtr, animated: true)
    }
}

class SettingsNoteAction: ProTapAction<SettingsItem> {
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        let tax = Account.allObjects(context: model.context).first!
        let nCtr = NoteController.show(item: tax)
        Analytics.settingsNote.logEvent()
        ctr.present(nCtr, animated: true)
    }
}

class SettingsBusinessSettingsAction: ProTapAction<SettingsItem> {
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let nCtr = R.storyboard.settings.businessSettingsRootController() else {
            return
        }
        
        Analytics.settingsBusinessSettings.logEvent()
        ctr.present(nCtr, animated: true)
    }
}
