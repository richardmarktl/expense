//
//  NewsletterAction.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import CommonUtil
import CommonUI

open class NewsletterAction: TapActionable {
    public var analytics: (() -> ())?

    public typealias RowActionType = SettingsItem
    public typealias SenderType = UITableView

    public func performTap(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {

        let alert = UIAlertController(
                title: PodLocalizedString("subscribeToNewsletter"),
                message: PodLocalizedString("pleaseEnterEmailAndHit"),
                preferredStyle: .alert
        )

        var externalTxt: UITextField?
        alert.addTextField { (txt) in
            txt.placeholder = PodLocalizedString("email")
            txt.keyboardType = UIKeyboardType.emailAddress
            externalTxt = txt
        }

        let subscribe = UIAlertAction(
                title: PodLocalizedString("subscribe"),
                style: UIAlertAction.Style.default) { (_) in
            if let email = externalTxt?.text {
                self.subscribe(email: email)
            }

            sender.deselectRow(at: indexPath, animated: true)
        }
        alert.addAction(subscribe)

        let cancel = UIAlertAction(title: PodLocalizedString("cancel"), style: .cancel) { (_) in
            sender.deselectRow(at: indexPath, animated: true)
        }
        alert.addAction(cancel)
        if let analytics = self.analytics {
            analytics();
        }
        ctr.present(alert, animated: true)
    }

    public func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {

    }

    public func subscribe(email: String) {
        fatalError("Subclass has not implemented abstract method `subscribe`!")
    }
}
