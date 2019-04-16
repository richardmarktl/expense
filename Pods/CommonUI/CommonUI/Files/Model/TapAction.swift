//
//  TapAction.swift
//  InVoice
//
//  Created by Georg Kitz on 14/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

public protocol TapActionable {
    var analytics: (() -> ())? { get set }
    associatedtype RowActionType
    associatedtype SenderType

    func canPerformTap(with rowItem: RowActionType, indexPath: IndexPath, sender: SenderType, ctr: UIViewController, model: Model<SenderType>) -> Bool
    func performTap(with rowItem: RowActionType, indexPath: IndexPath, sender: SenderType, ctr: UIViewController, model: Model<SenderType>)
    func rewindAction(with rowItem: RowActionType, indexPath: IndexPath, sender: SenderType, ctr: UIViewController, model: Model<SenderType>)
}

public extension TapActionable {
    func canPerformTap(with rowItem: RowActionType, indexPath: IndexPath, sender: SenderType, ctr: UIViewController, model: Model<SenderType>) -> Bool {
        return true
    }
}
