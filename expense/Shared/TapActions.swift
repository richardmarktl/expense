//
//  TapActions.swift
//  InVoice
//
//  Created by Georg Kitz on 22/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI

class TapAction<ItemType>: TapActionable {
    var analytics: (() -> ())?

    typealias RowActionType = ItemType
    typealias SenderType = UITableView

    func performTap(with rowItem: ItemType, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        sender.deselectRow(at: indexPath, animated: true)
    }

    func rewindAction(with rowItem: ItemType, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {

    }
}

class CollectionTapAction<ItemType>: TapActionable {
    var analytics: (() -> ())?

    typealias RowActionType = ItemType
    typealias SenderType = UICollectionView

    func performTap(with rowItem: ItemType, indexPath: IndexPath, sender: UICollectionView, ctr: UIViewController, model: Model<UICollectionView>) {
        sender.deselectItem(at: indexPath, animated: true)
    }

    func rewindAction(with rowItem: ItemType, indexPath: IndexPath, sender: UICollectionView, ctr: UIViewController, model: Model<UICollectionView>) {
    }
}

//class FirstResponderActionTextViewCell: TapAction<TextEntry> {
//
//    override func performTap(with rowItem: TextEntry, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: TableModel<UITableView>) {
//
////        if (isProExpired) {
////            super.performTap(with: rowItem, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
////            return
////        }
//
//        guard let cell = sender.cellForRow(at: indexPath) as? TextViewCell else {
//            return
//        }
//
//        cell.textView.isUserInteractionEnabled = true
//        _ = cell.textView.becomeFirstResponder()
//    }
//
//    override func rewindAction(with rowItem: TextEntry, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: TableModel<UITableView>) {
//        guard let cell = sender.cellForRow(at: indexPath) as? TextViewCell else {
//            return
//        }
//
//        _ = cell.textView.resignFirstResponder()
//        cell.textView.isUserInteractionEnabled = false
//    }
//}

class FirstResponderActionTextFieldCell: TapAction<TextEntry> {
    typealias RowActionType = TextEntry
    
    override func performTap(with rowItem: TextEntry, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        guard let cell = sender.cellForRow(at: indexPath) as? TextFieldCell else {
            return
        }
        
        cell.textField.isUserInteractionEnabled = true
        _ = cell.textField.becomeFirstResponder()
    }
    
    override func rewindAction(with rowItem: TextEntry, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        guard let cell = sender.cellForRow(at: indexPath) as? TextFieldCell else {
            return
        }
        
        _ = cell.textField.resignFirstResponder()
        cell.textField.isUserInteractionEnabled = false
    }
}

class FirstResponderActionNumberCell: TapAction<NumberEntry> {
    typealias RowActionType = NumberEntry

    override func performTap(with rowItem: NumberEntry, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        guard let cell = sender.cellForRow(at: indexPath) as? NumberCell else {
            return
        }

        cell.textField.isUserInteractionEnabled = true
        _ = cell.textField.becomeFirstResponder()
    }

    override func rewindAction(with rowItem: NumberEntry, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        guard let cell = sender.cellForRow(at: indexPath) as? NumberCell else {
            return
        }

        _ = cell.textField.resignFirstResponder()
        cell.textField.isUserInteractionEnabled = false
    }
}
//
//class FirstResponderActionDiscountCell: ProTapAction<DiscountEntry> {
//    typealias RowActionType = DiscountEntry
//
//    override func performTap(with rowItem: DiscountEntry, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: TableModel<UITableView>) {
//
//        if (isProExpired) {
//            super.performTap(with: rowItem, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
//            return
//        }
//
//        guard let cell = sender.cellForRow(at: indexPath) as? DiscountCell else {
//            return
//        }
//
//        cell.textField.isUserInteractionEnabled = true
//        _ = cell.textField.becomeFirstResponder()
//    }
//
//    override func rewindAction(with rowItem: DiscountEntry, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: TableModel<UITableView>) {
//        guard let cell = sender.cellForRow(at: indexPath) as? DiscountCell else {
//            return
//        }
//
//        _ = cell.textField.resignFirstResponder()
//        cell.textField.isUserInteractionEnabled = false
//    }
//}
