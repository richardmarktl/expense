//
//  ShareAction.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import CommonUI
import CommonUtil

open class ShareAction: TapActionable {
    public var analytics: (() -> ())?

    public typealias RowActionType = SettingsItem
    public typealias SenderType = UITableView

    public func performTap(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {

        let message = PodLocalizedString("shareAppMessage", comment: "")
        let activityCtr = UIActivityViewController(activityItems: [message], applicationActivities: nil)

        if UIDevice.current.userInterfaceIdiom == .pad {
            activityCtr.popoverPresentationController?.sourceView = sender.cellForRow(at: indexPath)
            activityCtr.popoverPresentationController?.sourceRect = sender.cellForRow(at: indexPath)?.bounds ?? CGRect.zero
        }

        if let analytics = self.analytics {
            analytics();
        }
        ctr.present(activityCtr, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            sender.deselectRow(at: indexPath, animated: true)
        }
    }

    public func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
    }
}