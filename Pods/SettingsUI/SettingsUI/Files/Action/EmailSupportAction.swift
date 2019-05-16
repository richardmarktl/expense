//
//  EmailSupportAction.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import SupportEmail
import CommonUtil
import CommonUI

open class EmailSupportAction: TapActionable {
    public var analytics: (() -> ())?

    private var emailSupport: SupportEmail?
    public typealias RowActionType = SettingsItem
    public typealias SenderType = UITableView

    public func performTap(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        emailSupport = SupportEmail()
        emailSupport?.sendAsTextFile = true

        if let analytics = self.analytics {
            analytics();
        }

        emailSupport?.send(to: [AppInfo.feedbackEmail], subject: AppInfo.name + " - " + UUID().uuidString.lowercased(), from: ctr, completion: { (state, error) in
            if state == .failed {
                if let error = error {
                    ErrorPresentable.show(error: error)
                } else {
                    ErrorPresentable.show(error: PodLocalizedString("noMailApp"))
                }
            }
            sender.deselectRow(at: indexPath, animated: true)
        })
    }

    public func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
    }
}