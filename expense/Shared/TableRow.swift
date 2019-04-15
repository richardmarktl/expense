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
    var identifier: String { get }
    var reuseIdentifier: String { get }
    func configure(_ cell: UIView)
}

protocol ControllerActionable {
    associatedtype SenderType
    func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel)
    func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel) -> Bool
    func rewindAction(sender: SenderType, in ctr: UIViewController, model: TableModel)
}


class TableRow<CellType: ConfigurableCell, CellAction: TapActionable>: ConfigurableRow, ControllerActionable where CellAction.RowActionType == CellType.ConfigType, CellAction.SenderType == UICollectionView {
    typealias SenderType = SenderType

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

    // MARK: ControllerActionable Implementation -
    func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel) {
        self.indexPath = indexPath
    }

    func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel) -> Bool {
        return action.canPerformTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    func rewindAction(sender: SenderType, in ctr: UIViewController, model: TableModel) {
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
        action.rewindAction(with: item, indexPath: newIndexPath, sender: sender, ctr: ctr, model: model)
    }
}

class GridRow<CellType: ConfigurableCell, CellAction: TapActionable>: ConfigurableRow, ControllerActionable where CellAction.RowActionType == CellType.ConfigType, CellAction.SenderType == UICollectionView {
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

    // MARK: ControllerActionable Implementation -
    func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel) {
        self.indexPath = indexPath
    }

    func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel) -> Bool {
        return action.canPerformTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    func rewindAction(sender: SenderType, in ctr: UIViewController, model: TableModel) {
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
        action.rewindAction(with: item, indexPath: newIndexPath, sender: sender, ctr: ctr, model: model)
    }
}
