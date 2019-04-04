//
//  OrderViewCell.swift
//  InVoice
//
//  Created by Richard Marktl on 22.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class OrderViewCell: UITableViewCell, ActionCellProtocol {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cornerView: CornerView!
    
    var action: VoiceAction? {
        didSet {
            if let action = action as? ItemFoundVoiceAction {
                nameLabel.text = action.item.itemDescription
                detailLabel.text = "0 x " + (action.item.price?.asCurrency(currencyCode: nil) ?? NSDecimalNumber.zero.asCurrency(currencyCode: nil))
                priceLabel.text = NSDecimalNumber.zero.asCurrency(currencyCode: nil)
            }
            
            if let action = action as? OrderVoiceAction {
                nameLabel.text = action.order.itemDescription
                detailLabel.text = "\(action.order.quantity?.asString() ?? "0") x \(action.order.price?.asCurrency(currencyCode: nil) ?? NSDecimalNumber.zero.asCurrency(currencyCode: nil))"
                if let price: NSDecimalNumber = action.order.price, let amount: NSDecimalNumber = action.order.quantity {
                    priceLabel.text = (price * amount).asCurrency(currencyCode: nil)
                } else {
                    priceLabel.text = NSDecimalNumber.zero.asCurrency(currencyCode: nil)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = UIView()
        view.backgroundColor = UIColor.white
        selectedBackgroundView = view
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        cornerView.backgroundColor = highlighted ? cornerView.borderColor : UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cornerView.backgroundColor = selected ? cornerView.borderColor : UIColor.white
    }
}
