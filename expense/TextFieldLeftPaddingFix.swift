//
//  TextFieldLeftPaddingFix.swift
//  InVoice
//
//  Created by Georg Kitz on 15/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

extension UITextField {
    
    class func mw_selectorReplacement() {
        
        let origPlaceholderRect = #selector(placeholderRect(forBounds:))
        let swizzeledPlaceholderRect = #selector(mw_placeholderRect(forBounds:))
        swizzling(UITextField.self, origPlaceholderRect, swizzeledPlaceholderRect)
        
        let origTextRect = #selector(textRect(forBounds:))
        let swizzeledTextRect = #selector(mw_textRect(forBounds:))
        swizzling(UITextField.self, origTextRect, swizzeledTextRect)
        
        let origEditingTextRect = #selector(editingRect(forBounds:))
        let swizzeledEditingTextRect = #selector(mw_editingRect(forBounds:))
        swizzling(UITextField.self, origEditingTextRect, swizzeledEditingTextRect)
    }
    
    @objc func mw_placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = mw_placeholderRect(forBounds: bounds)
        if let leftViewFrame = leftView?.frame, leftViewFrame.maxX == rect.minX {
            return CGRect(x: rect.minX + 8, y: rect.minY, width: rect.width - 8, height: rect.height)
        }
        return rect
    }
    
    @objc func mw_textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = mw_textRect(forBounds: bounds)
        if let leftViewFrame = leftView?.frame, leftViewFrame.maxX == rect.minX {
            let newRect = CGRect(x: rect.minX + 8, y: rect.minY, width: rect.width - 8, height: rect.height)
            return newRect
        }
        return rect
    }
    
    @objc func mw_editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = mw_editingRect(forBounds: bounds)
        if let leftViewFrame = leftView?.frame, leftViewFrame.maxX == rect.minX {
            let newRect = CGRect(x: rect.minX + 8, y: rect.minY, width: rect.width - 8, height: rect.height)
            return newRect
        }
        return rect
    }
}
