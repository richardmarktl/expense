//
//  JobCell.swift
//  InVoice
//
//  Created by Georg Kitz on 12/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

extension JobState {
    var color: UIColor {
        switch self {
        case .notSend:
            return UIColor.main
        case .opened:
            return UIColor.orangeish
        case .downloaded:
            return UIColor.purpleish
        case .signed:
            return UIColor.rose
        default:
            return UIColor.greenish
        }
    }
    
    var title: String {
        switch self {
        case .notSend:
            return R.string.localizable.stateNotSend()
        case .opened:
            return R.string.localizable.stateOpened()
        case .downloaded:
            return R.string.localizable.stateOpenedLink()
        case .signed:
            return R.string.localizable.stateSigned()
        default:
            return R.string.localizable.stateSent()
        }
    }
}

class JobCell: UITableViewCell {
    
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var invoiceNumberLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeView!
    
    var item: JobItem? {
        didSet {
            guard let item = item else {
                return
            }
            
            customerLabel.text = item.client
            invoiceNumberLabel.text = item.externalId
            dueLabel.text = item.timeString
            totalLabel.text = item.totalString
            badgeView.isHidden = item is PaidInvoice
            badgeView.badgeColor = item.state.color
            badgeView.title = item.state.title
            #if DEBUG
                customerLabel.accessibilityIdentifier = "customer_label_" + item.client
                let id = item.externalId
                    .replacingOccurrences(of: R.string.localizable.inv(), with: "")
                    .replacingOccurrences(of: R.string.localizable.est(), with: "")
                invoiceNumberLabel.accessibilityIdentifier = "invoice_number_" + id
                dueLabel.accessibilityIdentifier = "due_date_" + item.timeString
                totalLabel.accessibilityIdentifier = "total_" + item.totalString
                badgeView.accessibilityIdentifier = "badge_" + String(item.state.rawValue)
            #endif
        }
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
