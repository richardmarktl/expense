//
//  BadgeView.swift
//  InVoice
//
//  Created by Georg Kitz on 12/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

@IBDesignable
class BadgeView: UIView, XibSetupable {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBInspectable var title: String = "" {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var badgeColor: UIColor = UIColor.main {
        didSet {
            setProperties()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = titleLabel.intrinsicContentSize
        size.width += 16
        size.height += 2
        return size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromXib()
        setProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromXib()
        setProperties()
    }
    
    private func setProperties() {
        titleLabel?.text = title
        
        backgroundColor = badgeColor
        rootView?.backgroundColor = badgeColor
        titleLabel.backgroundColor = badgeColor
        
        rootView?.layer.cornerRadius = 4
        layer.cornerRadius = 4
    }
}
