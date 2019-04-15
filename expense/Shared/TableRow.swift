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

protocol ControllerActionable: ConfigurableRow {
    associatedtype SenderType
    func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel<SenderType>)
    func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel<SenderType>) -> Bool
    func rewindAction(sender: SenderType, in ctr: UIViewController, model: TableModel<SenderType>)
}

class Row<T>: ControllerActionable {
    typealias SenderType = T
    var indexPath: IndexPath?


    let identifier: String = UUID().uuidString.lowercased()
    private(set) var reuseIdentifier: String = ""
    func configure(_ cell: UIView) {
    }

    // MARK: ControllerActionable Implementation -

    func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel<SenderType>) {
        self.indexPath = indexPath
    }

    func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: TableModel<SenderType>) -> Bool {
        return true
    }

    func rewindAction(sender: SenderType, in ctr: UIViewController, model: TableModel<SenderType>) {

    }
}

class TableRow<CellType: ConfigurableCell, CellAction: TapActionable>: Row<UITableView>
        where CellAction.RowActionType == CellType.ConfigType, TableRow.SenderType == CellAction.SenderType {
    let item: CellType.ConfigType
    let action: CellAction

    override var reuseIdentifier: String {
        return CellType.reuseIdentifier
    }

    init(item: CellType.ConfigType, action: CellAction) {
        self.item = item
        self.action = action
    }

    override func configure(_ cell: UIView) {
        (cell as? CellType)?.configure(with: item)
    }

    // MARK: ControllerActionable Implementation -
    override func performTap(indexPath: IndexPath, sender: UITableView, in ctr: UIViewController, model: TableModel<UITableView>) {
        self.indexPath = indexPath
        self.action.performTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    override func canPerformTap(indexPath: IndexPath, sender: UITableView, in ctr: UIViewController, model: TableModel<UITableView>) -> Bool {
        return action.canPerformTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    override func rewindAction(sender: UITableView, in ctr: UIViewController, model: TableModel<UITableView>) {
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

class GridRow<CellType: ConfigurableCell, CellAction: TapActionable>: Row<UICollectionView>
        where CellAction.RowActionType == CellType.ConfigType, GridRow.SenderType == CellAction.SenderType {
    let item: CellType.ConfigType
    let action: CellAction

    override var reuseIdentifier: String {
        return CellType.reuseIdentifier
    }

    init(item: CellType.ConfigType, action: CellAction) {
        self.item = item
        self.action = action
    }

    override func configure(_ cell: UIView) {
        (cell as? CellType)?.configure(with: item)
    }

    // MARK: ControllerActionable Implementation -
    override func performTap(indexPath: IndexPath, sender: UICollectionView, in ctr: UIViewController, model: TableModel<UICollectionView>) {
        self.indexPath = indexPath
        self.action.performTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    override func canPerformTap(indexPath: IndexPath, sender: UICollectionView, in ctr: UIViewController, model: TableModel<UICollectionView>) -> Bool {
        return action.canPerformTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    override func rewindAction(sender: UICollectionView, in ctr: UIViewController, model: TableModel<UICollectionView>) {
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