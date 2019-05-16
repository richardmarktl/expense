//
//  SettingsCell.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import CommonUI

class SettingsCell: UITableViewCell, ConfigurableCell {
    typealias ConfigType = SettingsItem

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var badgeContainer: UIView!
    @IBOutlet weak var badgeView: BadgeView!

    func configure(with item: SettingsItem) {
        itemImageView.image = item.image
        itemLabel.text = item.title
        itemLabel.accessibilityIdentifier = item.accessibilityIdentifier
        badgeContainer.isHidden = !item.isProFeature
    }

    // The stupid cell, makes every background translucent on select/highlight, we don't want that for the badge
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = badgeView.badgeColor
        super.setSelected(selected, animated: animated)
        badgeView.badgeColor = color
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = badgeView.badgeColor
        super.setHighlighted(highlighted, animated: animated)
        badgeView.badgeColor = color
    }
}
