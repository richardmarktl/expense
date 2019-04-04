//
//  UIFont+Fira.swift
//  meisterwork
//
//  Created by Georg Kitz on 23/04/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

import UIKit

enum FiraSans: String {
    case bold = "Bold"
    case book = "Book"
    case eight = "Eight"
    case extraBold = "ExtraBold"
    case extraLight = "ExtraLight"
    case four = "Four"
    case hair = "Hair"
    case heavy = "Heavy"
    case italic = "Italic"
    case light = "Light"
    case medium = "Medium"
    case regular = "Regular"
    case semiBold = "SemiBold"
    case thin = "Thin"
    case two = "Two"
    case ultra = "Ultra"
    case ultraLight = "UltraLight"
    
    func font(_ size: CGFloat, italic: Bool = false) -> UIFont {
        return UIFont.font(self, size: size, italic: italic)
    }
}

extension UIFont {
    
    class func font(_ type: FiraSans, size: CGFloat, italic: Bool = false) -> UIFont {
        
        var font = "FiraSans-" + type.rawValue
        if italic {
            font += "Italic"
        }
    
        if let font = UIFont(name: font, size: size) {
            return font
        }
        return systemFont(ofSize: size)
    }
    
}

extension UIFont {
    class func headerFooterFont() -> UIFont {
        return FiraSans.regular.font(13)
    }
}
