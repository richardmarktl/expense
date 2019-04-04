//
//  ErrorView.swift
//  InVoice
//
//  Created by Richard Marktl on 15.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class ErrorView: UIView, XibSetupable {
    @IBOutlet weak var label: UILabel?
    @IBInspectable var text: String? {
        didSet {
            setProperties()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromXib()
        setProperties()
    }
    
    private func setProperties() {
        label?.text = text
    }
}
