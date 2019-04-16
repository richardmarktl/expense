//
//  UserCell.swift
//  InVoice
//
//  Created by Georg Kitz on 23/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class UserCell: ReusableTableViewCell, ConfigurableCell {
    typealias ConfigType = UserItem
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(with item: UserItem) {
        nameLabel.text = item.name
    }
}
