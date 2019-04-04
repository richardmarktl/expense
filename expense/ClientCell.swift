//
//  ClientPickCell.swift
//  InVoice
//
//  Created by Georg Kitz on 16/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class ClientCell: UITableViewCell, ConfigurableCell {
    typealias ConfigType = ClientItem
    
    func configure(with item: ClientItem) {
        textLabel?.text = item.clientName
        detailTextLabel?.text = item.clientInfo
    }
}
