//
//  ProSectionAction.swift
//  InVoice
//
//  Created by Georg Kitz on 05/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class ProSectionAction: TapActionable {
    
    typealias RowActionType = SettingsItem
    
    func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        UpsellTrialExpiredController.present(in: ctr)
    }
    
    func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
    }
}

class BackupAction: ProSectionAction {
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        Analytics.settingsBackup.logEvent()
        
        if !rowItem.allowToAccessProFeature {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        guard let bCtr = R.storyboard.settings.backupViewController() else {
            return
        }
        bCtr.context = model.context
        ctr.navigationController?.pushViewController(bCtr, animated: true)
    }
}

class ReadReceiptAction: ProSectionAction {
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        Analytics.settingsReadReceipt.logEvent()
        
        if !rowItem.allowToAccessProFeature {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        guard let bCtr = R.storyboard.settings.emailReceiptPermissionController() else {
            return
        }
        
        ctr.navigationController?.pushViewController(bCtr, animated: true)
    }
}

class ThemeAction: ProSectionAction {
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        Analytics.settingsThemes.logEvent()
        
        if !rowItem.allowToAccessProFeature {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        ctr.performSegue(withIdentifier: R.segue.settingsController.show_theme_ctr.identifier, sender: nil)
    }
}

class SettingsPaymentProviderAction: ProSectionAction {
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        Analytics.settingsPaymentProvider.logEvent()
        
        if !rowItem.allowToAccessProFeature {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        let segueId = R.segue.settingsController.show_payment_provider_ctr.identifier
        ctr.performSegue(withIdentifier: segueId, sender: nil)
    }
}


class SignatureAction: ProSectionAction {
    override func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        Analytics.settingsSignature.logEvent()
        
        if !rowItem.allowToAccessProFeature {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        let segueId = R.segue.settingsController.show_signature_ctr.identifier
        ctr.performSegue(withIdentifier: segueId, sender: nil)
    }
}
