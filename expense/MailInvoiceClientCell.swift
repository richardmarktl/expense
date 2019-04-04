//
// Created by Richard Marktl on 31.01.18.
// Copyright (c) 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class MailInvoiceClientCell: UITableViewCell, ConfigurableCell {
    typealias ConfigType = ClientOverviewItem

    func configure(with item: ClientOverviewItem) {
        textLabel?.text = item.client
        detailTextLabel?.text = item.item.email
        textLabel?.textColor = item.hasEmail ? .black : .lightGray
    }
}
