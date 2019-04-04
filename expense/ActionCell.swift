//
//  ActionCell.swift
//  InVoice
//
//  Created by Georg Kitz on 26/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

class ActionCell: ReusableCell, ConfigurableCell {
    
    typealias ConfigType = ActionItem
    
    func configure(with item: ActionItem) {
        textLabel?.text = item.title
        textLabel?.accessibilityLabel = item.accessibilityIdentifier
        textLabel?.textColor = item.isEnabled ? .blackish : .blueGrayish
    }
}
