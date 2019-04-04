//
//  PageSizeCell.swift
//  InVoice
//
//  Created by Richard Marktl on 10.01.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import UIKit

class PageSizeSelectCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = PageSelectItem
    
    func configure(with item: PageSelectItem) {
        textLabel?.text = item.size.localizedString
        #if DEBUG
        textLabel?.accessibilityIdentifier = "select_size_item_" + item.size.rawValue
        #endif
        accessoryType = item.isSelected ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
    }
}
