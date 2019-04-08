//
//  TableRow.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

protocol ConfigurableRow {
    var identifier: String {get}
    var reuseIdentifier: String {get}
    func configure(_ cell: UIView)
    func performTap(indexPath: IndexPath, tableView: UITableView, in ctr: UIViewController, model: TableModel)
    func canPerformTap(indexPath: IndexPath, tableView: UITableView, in ctr: UIViewController, model: TableModel) -> Bool
    func rewindAction(tableView: UITableView, in ctr: UIViewController, model: TableModel)
}

class TableRow<CellType: ConfigurableCell, CellAction: TapActionable>: ConfigurableRow where
CellAction.RowActionType == CellType.ConfigType {

    let identifier: String = UUID().uuidString.lowercased()
    
    var indexPath: IndexPath?
    let item: CellType.ConfigType
    let action: CellAction
    
    var reuseIdentifier: String {
        return CellType.reuseIdentifier
    }
    
    init(item: CellType.ConfigType, action: CellAction) {
        self.item = item
        self.action = action
    }
    
    func configure(_ cell: UIView) {
        (cell as? CellType)?.configure(with: item)
    }
    
    func performTap(indexPath: IndexPath, tableView: UITableView, in ctr: UIViewController, model: TableModel) {
        action.performTap(with: item, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
        self.indexPath = indexPath
    }
    
    func rewindAction(tableView: UITableView, in ctr: UIViewController, model: TableModel) {
        guard let indexPath = indexPath else {
            return
        }
        
        defer {
            self.indexPath = nil
        }
        
        var index = NSNotFound
        model.sections[indexPath.section].rows.enumerated().forEach { (idx, item) in
            if item.identifier == self.identifier {
                index = idx
            }
        }
        
        if index == NSNotFound {
            return
        }
        
        let newIndexPath = IndexPath(row: index, section: indexPath.section)
        action.rewindAction(with: item, indexPath: newIndexPath, tableView: tableView, ctr: ctr, model: model)
    }
    
    func canPerformTap(indexPath: IndexPath, tableView: UITableView, in ctr: UIViewController, model: TableModel) -> Bool {
        return action.canPerformTap(with: item, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
    }
}
