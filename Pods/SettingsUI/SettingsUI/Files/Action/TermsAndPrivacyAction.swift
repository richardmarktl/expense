//
//  TermsAndPrivacyAction.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import CommonUI

open class TermsAndPrivacyAction: TapActionable {
    public var analytics: (() -> ())?

    public typealias RowActionType = SettingsItem
    public typealias SenderType = UITableView

    public func performTap(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        let pCtr = PrivacyController(nibName: nil, bundle: nil)
        if let analytics = self.analytics {
            analytics();
        }
        ctr.navigationController?.pushViewController(pCtr, animated: true)
    }

    public func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
    }
}
