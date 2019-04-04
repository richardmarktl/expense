//
//  TapAction.swift
//  InVoice
//
//  Created by Georg Kitz on 14/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

protocol TapActionable {
    associatedtype RowActionType
    func canPerformTap(with rowItem: RowActionType, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) -> Bool
    func performTap(with rowItem: RowActionType, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel)
    func rewindAction(with rowItem: RowActionType, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel)
}

extension TapActionable {
    func canPerformTap(with rowItem: RowActionType, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) -> Bool {
        return true
    }
}

class ProTapAction<ItemType>: TapActionable {
    typealias RowActionType = ItemType
    
    var isProExpired: Bool {
        return CurrentAccountState.value == .trialExpired;
    }
    
    func performTap(with rowItem: ItemType, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        tableView.deselectRow(at: indexPath, animated: true)
        UpsellTrialExpiredController.present(in: ctr)
    }
    
    func rewindAction(with rowItem: ItemType, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}
