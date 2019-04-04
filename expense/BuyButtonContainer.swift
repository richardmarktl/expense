//
//  BuyButton.swift
//  InVoice
//
//  Created by Georg Kitz on 24/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

//
//  ActionButton.swift
//  InVoice
//
//  Created by Georg Kitz on 19/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

@IBDesignable
class BuyButton: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let val = super.beginTracking(touch, with: event)
        if let first = subviews.first as? UIImageView {
            first.isHighlighted = true
        }
        return val
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let first = subviews.first as? UIImageView {
            first.isHighlighted = false
        }
        super.endTracking(touch, with: event)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        if let first = subviews.first as? UIImageView {
            first.isHighlighted = false
        }
        super.cancelTracking(with: event)
    }
}

@IBDesignable
class BuyButtonContainer: UIView, XibSetupable {
    
    @IBOutlet weak var button: BuyButton?
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    
    var tapObservable: Observable<Void> {
        return button?.rx.controlEvent(.touchUpInside).mapToVoid().asObservable() ?? Observable.empty()
    }
    
    var leftText: String? {
        set {
            leftLabel.text = newValue
        }
        get {
            return leftLabel.text
        }
    }
    
    var rightText: String? {
        set {
            rightLabel.text = newValue
        }
        get {
            return rightLabel.text
        }
    }
    
    @IBInspectable var titleColor: UIColor? {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var color: UIColor? = nil {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var borderColor: UIColor? = nil {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var highlightedColor: UIColor? = nil {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var borderHighlightedColor: UIColor? = nil {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var radius: CGFloat = 4 {
        didSet {
            setProperties()
        }
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
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: 52)
    }
    
    private func setProperties() {
        
        backgroundColor = UIColor.clear
        
        if let borderColor = borderColor {
            backgroundView.image = UIImage.borderImageWithColor(borderColor, cornerRadius: radius, borderWidth: 1)
        }
        
        if let borderHighlightColor = borderHighlightedColor {
            backgroundView.highlightedImage = UIImage.borderImageWithColor(borderHighlightColor, cornerRadius: radius, borderWidth: 1)
        }
        
        if let color = color {
            backgroundView.image = UIImage.imageWithColor(color, cornerRadius: radius)
        }
        
        if let highlightedColor = highlightedColor {
            backgroundView.highlightedImage = UIImage.imageWithColor(highlightedColor, cornerRadius: radius)
        }
        
        leftLabel.textColor = titleColor
        rightLabel.textColor = titleColor
        
        clipsToBounds = true
    }
}
