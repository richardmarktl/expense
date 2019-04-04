//
//  ClientsCell.swift
//  InVoice
//
//  Created by Georg Kitz on 16/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class ClientsCell: ReusableCell, ConfigurableCell {
    
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    typealias ConfigType = ClientOverviewItem

    func configure(with item: ClientOverviewItem) {
        customerLabel.text = item.client
        addressLabel.text = item.address
        idLabel.text = item.identifier
    }
}
