//
//  SettingsCell.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell, ConfigurableCell {
    typealias ConfigType = SettingsItem
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var badgeContainer: UIView!
    @IBOutlet weak var badgeView: BadgeView!
    
    func configure(with item: SettingsItem) {
        itemImageView.image = item.image
        itemImageView.tintColor = UIColor.main
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
