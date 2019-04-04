//
//  GradientLabel.swift
//  InVoice
//
//  Created by Georg Kitz on 26.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable
class GradientLabelView: GradientView {
    
    @IBOutlet weak var label: UILabel? {
        didSet {
            label?.isHidden = true
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return label?.intrinsicContentSize ?? super.intrinsicContentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let l = UILabel()
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.frame = label?.frame ?? .zero
        l.numberOfLines = label?.numberOfLines ?? 0
        l.font = label?.font
        l.text = label?.text
        mask = l
    }
}
