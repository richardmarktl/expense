//
//  TileCell.swift
//  InVoice
//
//  Created by Georg Kitz on 10/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

protocol Shadowable {
    func addShadow()
}

extension Shadowable where Self: UICollectionViewCell {
    func addShadow() {
        
        let view = backgroundView ?? contentView
        view.backgroundColor = UIColor.white
        update(view: view)
        
        if let selectedBackground = selectedBackgroundView {
            update(view: selectedBackground)
        }
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    private func update(view: UIView) {
        view.layer.cornerRadius = 4.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.masksToBounds = true
    }
}

class TileCell: UICollectionViewCell, Shadowable, ConfigurableCell {
    
    typealias ConfigType = TileItem
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeView!
    
    func configure(with item: TileItem) {
        titleLabel.text = item.title
        titleLabel.adjustsFontSizeToFitWidth = true
        
        descriptionLabel.text = item.description
        badgeView.isHidden = !item.showProBadge
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView = UIView()
        backgroundView?.backgroundColor = UIColor.green
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.tableViewSeparator
    }
}
