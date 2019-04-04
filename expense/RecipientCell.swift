//
// Created by Richard Marktl on 17.09.18.
// Copyright (c) 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class RecipientCell: ReusableCell, ConfigurableCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeView!

    typealias ConfigType = RecipientItem

    func configure(with item: RecipientItem) {
        titleLabel.text = item.title
        let state = item.value.typedState
        badgeView.badgeColor = state.color
        badgeView.title = state.title
        accessoryType = (state == .signed) ? .disclosureIndicator : .none
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
