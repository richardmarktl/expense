//
//  AccountDetailModel.swift
//  InVoice
//
//  Created by Georg Kitz on 24/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class OpenSubscriptionAction: TapActionable {
    typealias RowActionType = SettingsItem
    
    func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        Upsell3Controller.present(in: ctr, mode: .showYearlyOnlyAndSubscriptionButton)
    }
    
    func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}

class SubscribeToProAction: TapActionable {
    typealias RowActionType = SettingsItem
    
    func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        Upsell2Controller.present(in: ctr)
    }
    
    func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}

class AccountDetailModel: AccountBaseModel {
    
    required init(with context: NSManagedObjectContext) {
        super.init(with: context, sectionTitle: R.string.localizable.accountDetailsFooter())
        
        let rows: [ConfigurableRow]
        if CurrentAccountState.value == .pro {
            let subscriptionEntry = SettingsItem(image: R.image.settings_subscription_icon()!, title: R.string.localizable.manageYourSubscription(), isProFeature: false, allowToAccessProFeature: false)
            rows = [
                TableRow<SettingsCell, OpenSubscriptionAction>(item: subscriptionEntry, action: OpenSubscriptionAction())
            ]
        } else {
            let subscriptionEntry = SettingsItem(image: R.image.pro_icon()!, title: R.string.localizable.accountSubscribePRO(), isProFeature: false, allowToAccessProFeature: false)
            rows = [
                TableRow<SettingsCell, SubscribeToProAction>(item: subscriptionEntry, action: SubscribeToProAction())
            ]
        }
        
        var modifiedSections = sections
        modifiedSections.append(TableSection(rows: rows))
        sections = modifiedSections
    }
    
    required init(with context: NSManagedObjectContext, sectionTitle: String) {
        fatalError("init(with:sectionTitle:) has not been implemented")
    }
}
