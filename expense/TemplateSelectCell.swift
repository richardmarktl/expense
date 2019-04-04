//
//  TemplateSelectCell.swift
//  InVoice
//
//  Created by Georg Kitz on 09/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class TemplateSelectCell: ReusableCell, ConfigurableCell {
    
    typealias ConfigType = SelectItem
    
    func configure(with item: SelectItem) {
        textLabel?.text = item.template.localizedString
        #if DEBUG
        textLabel?.accessibilityIdentifier = "select_theme_item_" + item.template.rawValue
        #endif
        accessoryType = item.isSelected ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
    }
}
