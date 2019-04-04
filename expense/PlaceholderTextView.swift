//
//  PlaceholderTextView.swift
//  meisterwork
//
//  Created by Georg Kitz on 21/02/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxCocoa

@IBDesignable
class PlaceholderTextView: UITextView {
    
    fileprivate struct Static {
        static let defaultTopInset: CGFloat = -5
        static let bigCellsTopInset: CGFloat = -9
    }
    
    @IBInspectable var removeInsets: Bool = false {
        didSet {
            
            if removeInsets {
                textContainerInset = UIEdgeInsets(top: 8.0, left: -4.0, bottom: 8.0, right: -4.0)
            } else {
                textContainerInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0)
            }
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    fileprivate var placeholderLabel: UILabel = UILabel()
    fileprivate var floatingPlaceholderLabel: UILabel = UILabel()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubview(placeholderLabel)
        
        floatingPlaceholderLabel.alpha = 0
        addSubview(floatingPlaceholderLabel)
        
        updateViews()
        
        _ = self.rx.text
            .orEmpty
            .startWith(text)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [unowned self](text) -> Void in
                self.placeholderLabel.isHidden = text.count != 0
                
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
    
    @IBInspectable var placeholderText: String = "Your Placeholder" {
        didSet {
            placeholderLabel.text = NSLocalizedString(placeholderText, comment: "")
            floatingPlaceholderLabel.text = NSLocalizedString(placeholderText, comment: "")
        }
    }
    
    @IBInspectable var placeholderTopInset: CGFloat = Static.defaultTopInset {
        didSet {
            updateViews()
        }
    }
    
    fileprivate func updateViews() {
        clipsToBounds = false
        
        placeholderLabel.textColor = placeholderColor ?? textColor
        floatingPlaceholderLabel.textColor = (isFirstResponder ? floatingPlaceholderColor : placeholderColor) ?? textColor
        
        if let font = font {
            placeholderLabel.font = font
            
            let scaledSize = font.pointSize * (floatingPlaceholderFontFactor / 100.0)
            floatingPlaceholderLabel.font = UIFont(name: font.fontName, size: scaledSize)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let xOffest = textContainer.lineFragmentPadding + textContainerInset.left
        let yOffset = textContainerInset.top
        let width = frame.size.width - 2 * textContainer.lineFragmentPadding - textContainerInset.left - textContainerInset.right
        let height = placeholderLabel.font.lineHeight
        placeholderLabel.frame = CGRect(x: xOffest, y: yOffset, width: width, height: height)
    }
    
    override func becomeFirstResponder() -> Bool {
        floatingPlaceholderLabel.textColor = floatingPlaceholderColor ?? textColor
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        floatingPlaceholderLabel.textColor = placeholderColor ?? textColor
        return super.resignFirstResponder()
    }
    
    fileprivate func showFloatingPlaceholderIfNeeded() {
        
        if floatingPlaceholderLabel.alpha != 0 {
            return
        }
        
        let xOffset = textContainer.lineFragmentPadding + textContainerInset.left
        let yOffset = textContainerInset.top
        let width = frame.size.width - 2 * textContainer.lineFragmentPadding - textContainerInset.left - textContainerInset.right
        let height = floatingPlaceholderLabel.font.lineHeight
        
        floatingPlaceholderLabel.frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        floatingPlaceholderLabel.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.floatingPlaceholderLabel.alpha = 1.0
            self.floatingPlaceholderLabel.frame = CGRect(x: xOffset, y: self.placeholderTopInset, width: width, height: height)
        }, completion: nil)
    }
    
    fileprivate func hideFloatingPlaceholderIfNeeded() {
        
        if floatingPlaceholderLabel.alpha != 1 {
            return
        }
        
        let x = textContainer.lineFragmentPadding + textContainerInset.left
        let y = textContainerInset.top
        let w = frame.size.width - 2 * textContainer.lineFragmentPadding - textContainerInset.left - textContainerInset.right
        let h = floatingPlaceholderLabel.font.lineHeight
        
        floatingPlaceholderLabel.frame = CGRect(x: x, y: placeholderTopInset, width: w, height: h)
        floatingPlaceholderLabel.alpha = 1
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            self.floatingPlaceholderLabel.alpha = 0
            self.floatingPlaceholderLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        }, completion: nil)
    }
}
