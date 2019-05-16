//
//  RateAction.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import CommonUI

public class RateAction: TapActionable {
    public var analytics: (() -> ())?

    public typealias RowActionType = SettingsItem
    public typealias SenderType = UITableView

    public func performTap(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        if let analytics = self.analytics {
            analytics();
        }

        RatingDisplayable.showRatingDialog(openAppStore: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            sender.deselectRow(at: indexPath, animated: true)
        }
    }

    public func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
    }
}