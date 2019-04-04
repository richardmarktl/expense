//
//  PlaceholderTextField.swift
//  InVoice
//
//  Created by Georg Kitz on 19/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

@IBDesignable
class PlaceholderTextField: UITextField {
    fileprivate struct Static {
        static let defaultTopInset: CGFloat = -12
        static let bigTopInset: CGFloat = -16
    }
    fileprivate var floatingPlaceholderLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        floatingPlaceholderLabel.alpha = 0
        floatingPlaceholderLabel.text = placeholder
        
        addSubview(floatingPlaceholderLabel)
        
        _ = self.rx.text
            .orEmpty
            .takeUntil(self.rx.deallocated)
            .startWith(text ?? "")
            .subscribe(onNext: { [unowned self](text) -> Void in
                
                if text.count == 0 {
                    self.hideFloatingPlaceholderIfNeeded()
                } else {
                    self.showFloatingPlaceholderIfNeeded()
                }
            })
    }
    
    @IBInspectable var floatingPlaceholderFontFactor: CGFloat = 70 {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable var floatingPlaceholderTopInset: CGFloat = Static.defaultTopInset {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable var floatingPlaceholderColor: UIColor? {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable var placeholderColor: UIColor? {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable var floatingPlaceholderInvalidColor: UIColor? {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable var isValid: Bool = true {
        didSet {
            updateViews()
        }
    }
    
    override var placeholder: String? {
        didSet {
            floatingPlaceholderLabel.text = placeholder
            updateViews()
        }
    }
    
    fileprivate func updateViews() {
        clipsToBounds = false
        
        updatePlaceholedTextColor()
        
        if let font = font {
            
            let scaledSize = font.pointSize * (floatingPlaceholderFontFactor / 100.0)
            floatingPlaceholderLabel.font = UIFont(name: font.fontName, size: scaledSize)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let text = text, text.count == 0 {
            self.hideFloatingPlaceholderIfNeeded()
        } else {
            self.showFloatingPlaceholderIfNeeded()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let value = super.becomeFirstResponder()
        updatePlaceholedTextColor()
        return value
    }
    
    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        updatePlaceholedTextColor()
        return value
    }
    
    fileprivate func updatePlaceholedTextColor() {
        if isValid {
            floatingPlaceholderLabel.textColor = (isFirstResponder ? floatingPlaceholderColor : placeholderColor) ?? textColor
        } else {
            floatingPlaceholderLabel.textColor = floatingPlaceholderInvalidColor
        }
    }
    
    fileprivate func showFloatingPlaceholderIfNeeded() {
        
        if floatingPlaceholderLabel.alpha != 0 {
            return
        }
        
        let rect = textRect(forBounds: bounds)
        let xOffset = rect.minX
        let yOffset = rect.minY
        let width = rect.width
        let height = floatingPlaceholderLabel.font.lineHeight
        
        floatingPlaceholderLabel.frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        floatingPlaceholderLabel.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.floatingPlaceholderLabel.alpha = 1.0
            self.floatingPlaceholderLabel.frame = CGRect(x: xOffset, y: self.floatingPlaceholderTopInset, width: width, height: height)
        }, completion: nil)
    }
    
    fileprivate func hideFloatingPlaceholderIfNeeded() {
        
        if floatingPlaceholderLabel.alpha != 1 {
            return
        }
        
        let rect = textRect(forBounds: bounds)
        let x = rect.minX
        let y = rect.minY
        let w = rect.width
        let h = floatingPlaceholderLabel.font.lineHeight
        
        floatingPlaceholderLabel.frame = CGRect(x: x, y: floatingPlaceholderTopInset, width: w, height: h)
        floatingPlaceholderLabel.alpha = 1
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            self.floatingPlaceholderLabel.alpha = 0
            self.floatingPlaceholderLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        }, completion: nil)
    }
}
