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
class ActionButton: UIView, XibSetupable {
    
    @IBOutlet weak var button: UIButton?
    @IBOutlet weak var leftImageView: UIImageView?
    
    var tapObservable: Observable<Void> {
        return button?.rx.tap.asObservable() ?? Observable.empty()
    }
    
    @IBInspectable var title: String? {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var titleColor: UIColor? {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var disabledTextColor: UIColor? {
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
    
    @IBInspectable var image: UIImage? {
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
        
        backgroundColor = UIColor.clear
        
        if let borderColor = borderColor {
            button?.setBackgroundImage(UIImage.borderImageWithColor(borderColor, cornerRadius: radius, borderWidth: 1), for: .normal)
        }
        
        if let borderHighlightColor = borderHighlightedColor {
            button?.setBackgroundImage(UIImage.borderImageWithColor(borderHighlightColor, cornerRadius: radius, borderWidth: 1), for: .highlighted)
        }
        
        if let color = color {
            button?.setBackgroundImage(UIImage.imageWithColor(color, cornerRadius: radius), for: .normal)
        }
        
        if let highlightedColor = highlightedColor {
            button?.setBackgroundImage(UIImage.imageWithColor(highlightedColor, cornerRadius: radius), for: .highlighted)
        }
        
        button?.setTitle(title.asLocalizedString, for: .normal)
        button?.setTitleColor(titleColor, for: [])
        
        if let disabledTextColor = disabledTextColor {
            button?.setTitleColor(disabledTextColor, for: [.disabled])
        }
        
        leftImageView?.image = image
        
        #if DEBUG
            button?.accessibilityIdentifier = "button_" + (title ?? "no_title")
        #endif
        
        clipsToBounds = true
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: 52)
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        title = "Sample Title"
    }
}

extension Optional where Wrapped == String {
    var asLocalizedString: String? {
        guard let string = self else {
            return nil
        }
        return NSLocalizedString(string, comment: "")
    }
}
