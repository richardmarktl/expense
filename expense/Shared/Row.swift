//
//  Row.swift
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
    func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>)
    func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) -> Bool
    func rewindAction(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>)
}

class Row<T>: ControllerActionable {
    typealias SenderType = T
    var indexPath: IndexPath?
    let identifier: String = UUID().uuidString.lowercased()
    private(set) var reuseIdentifier: String = ""

    func configure(_ cell: UIView) {
    }

    // MARK: ControllerActionable Implementation -
    func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
    }

    func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) -> Bool {
        return true
    }

    func rewindAction(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
    }

}

class TableRow<CellType: ConfigurableCell, CellAction: TapActionable>: Row<UITableView>
        where CellAction.RowActionType == CellType.ConfigType, TableRow.SenderType == CellAction.SenderType {
    let item: CellType.ConfigType
    let action: CellAction

    override var reuseIdentifier: String {
        return CellType.reuseIdentifier
    }

    required init(item: CellType.ConfigType, action: CellAction) {
        self.item = item
        self.action = action
    }

    override func configure(_ cell: UIView) {
        (cell as? CellType)?.configure(with: item)
    }

    // MARK: ControllerActionable Implementation -
    override func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
        self.indexPath = indexPath
        self.action.performTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    override func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) -> Bool {
        return action.canPerformTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    override func rewindAction(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
        action.rewindAction(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }
}

class GridRow<CellType: ConfigurableCell, CellAction: TapActionable>: Row<UICollectionView>
        where CellAction.RowActionType == CellType.ConfigType, GridRow.SenderType == CellAction.SenderType {
    let item: CellType.ConfigType
    let action: CellAction

    override var reuseIdentifier: String {
        return CellType.reuseIdentifier
    }

    required init(item: CellType.ConfigType, action: CellAction) {
        self.item = item
        self.action = action
    }

    override func configure(_ cell: UIView) {
        (cell as? CellType)?.configure(with: item)
    }

    // MARK: ControllerActionable Implementation -
    override func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
        self.indexPath = indexPath
        self.action.performTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    override func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) -> Bool {
        return action.canPerformTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    override func rewindAction(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
        action.rewindAction(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }
}