//
//  UserCell.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import CommonUI


class SettingsUserCell: ReusableTableViewCell, ConfigurableCell {
    typealias ConfigType = UserItem

    @IBOutlet weak var nameLabel: UILabel!

    func configure(with item: UserItem) {
        nameLabel.text = item.name
    }
}
