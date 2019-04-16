//
//  KeyboardAccessoryable.swift
//  InVoice
//
//  Created by Georg Kitz on 20/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

/// This is basically just to wrap UITextField & UITextView in a single object
protocol AccessoryItemAble: NSObjectProtocol {
    var inputAccessoryView: UIView? {get set}
    func resignFirstResponder() -> Bool
}

extension UITextField: AccessoryItemAble {
    
}

extension UITextView: AccessoryItemAble {
    
}

/// Allows us to create a keyboard accessory view and registers it's events
protocol InputAccessoryAble {
    func registerAccessory(for item: AccessoryItemAble, customCenterView: UIView?)
}

// MARK: - Extends a ReusableCell so we can use the accesory from within it
extension InputAccessoryAble where Self: ReusableTableViewCell {
    
    func registerAccessory(for item: AccessoryItemAble, customCenterView: UIView? = nil) {
        
        let keyboardAccessoryView = KeyboardAccessory(frame: CGRect(x: 0, y: 0, width: 320, height: 44), customCenterView: customCenterView)
        item.inputAccessoryView = keyboardAccessoryView
        
        // Hide Keyboard Button
        keyboardAccessoryView.hideKeyboardObservable.subscribe(onNext: { (_) in
            _ = item.resignFirstResponder()
        }).disposed(by: reusableBag)
        
        // Down Keyboard Button
        keyboardAccessoryView.downObservable.subscribe(onNext: { [weak self](_) in
            
            guard let tableView = self?.superview(of: UITableView.self), let cell = self, let idx = tableView.indexPath(for: cell) else { return }
            
            let total = tableView.numberOfRows(inSection: idx.section)
            let next = idx.row + 1 == total ? 0 : idx.row + 1
            
            let newIdx = IndexPath(row: next, section: idx.section)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: newIdx)
            
        }).disposed(by: reusableBag)
        
        // Up Keyboard Button
        keyboardAccessoryView.upObservable.subscribe(onNext: { [weak self](_) in
            
            guard let tableView = self?.superview(of: UITableView.self), let cell = self, let idx = tableView.indexPath(for: cell) else { return }
            
            let total = tableView.numberOfRows(inSection: idx.section)
            let prev = idx.row == 0 ? total - 1 : idx.row - 1
            
            let newIdx = IndexPath(row: prev, section: idx.section)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: newIdx)
            
        }).disposed(by: reusableBag)
    }
}
