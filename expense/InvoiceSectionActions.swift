//
//  InvoiceSectionActions.swift
//  InVoice
//
//  Created by Georg Kitz on 22/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class DateAction: ProTapAction<DateItem> {
    
    override func performTap(with rowItem: DateItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        Analytics.changedDate.logEvent()
        
        rowItem.isExpanded = !rowItem.isExpanded
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    override func rewindAction(with rowItem: DateItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        if rowItem.isExpanded {
            performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
        }
    }
}

class PickerItemAction<T: PickerItemInterface>: ProTapAction<PickerItem<T>> {
    
    override func performTap(with rowItem: PickerItem<T>, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        rowItem.isExpanded = !rowItem.isExpanded
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    override func rewindAction(with rowItem: PickerItem<T>, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        if rowItem.isExpanded {
            performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
        }
    }
}

class LanguageAction: PickerItemAction<Language> {
    func performTap(with rowItem: LanguageItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.changeLanguage.logEvent()
        super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
    }
}

class CurrencyAction: PickerItemAction<Currency> {
    func performTap(with rowItem: CurrencyItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.changeCurrency.logEvent()
        super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
    }
}
