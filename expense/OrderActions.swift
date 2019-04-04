//
//  OrderActions.swift
//  InVoice
//
//  Created by Georg Kitz on 22/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class FirstResponderActionTextViewCell: ProTapAction<TextEntry> {
    
    override func performTap(with rowItem: TextEntry, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if (isProExpired) {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TextViewCell else {
            return
        }
        
        cell.textView.isUserInteractionEnabled = true
        _ = cell.textView.becomeFirstResponder()
    }
    
    override func rewindAction(with rowItem: TextEntry, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TextViewCell else {
            return
        }
        
        _ = cell.textView.resignFirstResponder()
        cell.textView.isUserInteractionEnabled = false
    }
}

class FirstResponderActionTextFieldCell: ProTapAction<TextEntry> {
    typealias RowActionType = TextEntry
    
    override func performTap(with rowItem: TextEntry, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if (isProExpired) {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell else {
            return
        }
        
        cell.textField.isUserInteractionEnabled = true
        _ = cell.textField.becomeFirstResponder()
    }
    
    override func rewindAction(with rowItem: TextEntry, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell else {
            return
        }
        
        _ = cell.textField.resignFirstResponder()
        cell.textField.isUserInteractionEnabled = false
    }
}

class FirstResponderActionNumberCell: ProTapAction<NumberEntry> {
    typealias RowActionType = NumberEntry
    
    override func performTap(with rowItem: NumberEntry, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if (isProExpired) {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? NumberCell else {
            return
        }
        
        cell.textField.isUserInteractionEnabled = true
        _ = cell.textField.becomeFirstResponder()
    }
    
    override func rewindAction(with rowItem: NumberEntry, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NumberCell else {
            return
        }
        
        _ = cell.textField.resignFirstResponder()
        cell.textField.isUserInteractionEnabled = false
    }
}

class FirstResponderActionDiscountCell: ProTapAction<DiscountEntry> {
    typealias RowActionType = DiscountEntry
    
    override func performTap(with rowItem: DiscountEntry, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if (isProExpired) {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? DiscountCell else {
            return
        }
        
        cell.textField.isUserInteractionEnabled = true
        _ = cell.textField.becomeFirstResponder()
    }
    
    override func rewindAction(with rowItem: DiscountEntry, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        guard let cell = tableView.cellForRow(at: indexPath) as? DiscountCell else {
            return
        }
        
        _ = cell.textField.resignFirstResponder()
        cell.textField.isUserInteractionEnabled = false
    }
}
