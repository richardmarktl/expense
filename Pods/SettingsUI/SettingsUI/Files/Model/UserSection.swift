//
//  UserSection.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import RxSwift
import CoreData
import CommonUtil
import CommonUI


public protocol UserItem {
    var name: String { get set }
    var email: String { get set }
}

public struct EmptyUserItem: UserItem {
    public var email: String = PodLocalizedString("No user email")
    public var name: String = PodLocalizedString("No user set")
}

open class UserDetailAction: TapActionable {
    public var analytics: (() -> ())?

    public typealias RowActionType = UserItem
    public typealias SenderType = UITableView

    public func performTap(with rowItem: UserItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        // override point
        if let analytics = analytics {
            analytics()
        }
    }

    public func rewindAction(with rowItem: UserItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {

    }
}

open class UserSection: Section<UITableView> {
    private let bag = DisposeBag()
    public var userItem: UserItem?

    init(userItem: UserItem?) {
        self.userItem = userItem
        let row: UserItem = (userItem != nil) ? userItem! : EmptyUserItem()
        let rows: [Row<UITableView>] = [
            TableRow<SettingsUserCell, UserDetailAction>(item: row, action: UserDetailAction())
        ]

        super.init(rows: rows)
    }
}
