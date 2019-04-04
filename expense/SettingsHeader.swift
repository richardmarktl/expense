//
//  SettingsHeader.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

@IBDesignable
class SettingsHeader: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = 4
        layer.borderColor = UIColor.tableViewSeparator.cgColor
        layer.borderWidth = 1
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let begin = super.beginTracking(touch, with: event)
        if begin {
            self.backgroundColor = UIColor.tableViewSeparator
        }
        return begin
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        self.backgroundColor = UIColor.white
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        self.backgroundColor = UIColor.white
    }
}
