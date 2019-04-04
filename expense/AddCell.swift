//
//  ClientCell.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

class AddCell: ReusableCell, ConfigurableCell {
    
    typealias ConfigType = AddItem
    
    func configure(with item: AddItem) {
        imageView?.image = item.image
        textLabel?.text = item.title
        #if DEBUG
            textLabel?.accessibilityIdentifier = "add_item_" + item.automatedTestingType.rawValue
        #endif
    }
}
