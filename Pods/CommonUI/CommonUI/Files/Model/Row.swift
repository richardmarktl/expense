//
//  Row.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//


import UIKit
import RxSwift

public protocol ConfigurableRow {
    var identifier: String { get }
    var reuseIdentifier: String { get }
    func configure(_ cell: UIView)
}

public protocol ControllerActionable: ConfigurableRow {
    associatedtype SenderType
    func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>)
    func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) -> Bool
    func rewindAction(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>)
}

open class Row<T>: ControllerActionable {
    public typealias SenderType = T
    public var indexPath: IndexPath?
    public let identifier: String = UUID().uuidString.lowercased()
    private(set) public var reuseIdentifier: String = ""

    public func configure(_ cell: UIView) {
    }

    // MARK: ControllerActionable Implementation -
    public func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
    }

    public func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) -> Bool {
        return true
    }

    public func rewindAction(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
    }
}

open class TableRow<CellType: ConfigurableCell, CellAction: TapActionable>: Row<UITableView>
        where CellAction.RowActionType == CellType.ConfigType, TableRow.SenderType == CellAction.SenderType {
    public let item: CellType.ConfigType
    public let action: CellAction

    public override var reuseIdentifier: String {
        return CellType.reuseIdentifier
    }

    public required init(item: CellType.ConfigType, action: CellAction) {
        self.item = item
        self.action = action
    }

    public override func configure(_ cell: UIView) {
        (cell as? CellType)?.configure(with: item)
    }

    // MARK: ControllerActionable Implementation -
    public override func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
        self.indexPath = indexPath
        self.action.performTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    public override func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) -> Bool {
        return action.canPerformTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    public override func rewindAction(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
        action.rewindAction(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }
}

open class GridRow<CellType: ConfigurableCell, CellAction: TapActionable>: Row<UICollectionView>
        where CellAction.RowActionType == CellType.ConfigType, GridRow.SenderType == CellAction.SenderType {
    public let item: CellType.ConfigType
    public let action: CellAction

    public override var reuseIdentifier: String {
        return CellType.reuseIdentifier
    }

    public required init(item: CellType.ConfigType, action: CellAction) {
        self.item = item
        self.action = action
    }

    public override func configure(_ cell: UIView) {
        (cell as? CellType)?.configure(with: item)
    }

    // MARK: ControllerActionable Implementation -
    public override func performTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
        self.indexPath = indexPath
        self.action.performTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    public override func canPerformTap(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) -> Bool {
        return action.canPerformTap(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }

    public override func rewindAction(indexPath: IndexPath, sender: SenderType, in ctr: UIViewController, model: Model<SenderType>) {
        action.rewindAction(with: item, indexPath: indexPath, sender: sender, ctr: ctr, model: model)
    }
}