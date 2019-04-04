//
//  UIColor+Extension.swift
//  Stargate
//
//  Created by Georg Kitz on 13/10/2017.
//  Copyright © 2017 DeliveryHero AG. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var main: UIColor {
        if let color = R.color.main() {
            return color
        }
        return UIColor(hexString: "#319FF9FF")
    }
    
    class var gray: UIColor {
        if let color = R.color.gray() {
            return color
        }
        return UIColor(hexString: "#898989FF")
    }
    
    class var mainHighlighted: UIColor {
        if let color = R.color.mainHighlighted() {
            return color
        }
        return UIColor(hexString: "#98CFFCFF")
    }
    
    class var redish: UIColor {
        if let color = R.color.redish() {
            return color
        }
        return UIColor(hexString: "#F13A30FF")
    }
    
    class var redishHighlighted: UIColor {
        if let color = R.color.redishHighlighted() {
            return color
        }
        return UIColor(hexString: "#F69C99FF")
    }
    
    class var greenish: UIColor {
        if let color = R.color.greenish() {
            return color
        }
        return UIColor(hexString: "#7ED321FF")
    }
    
    class var greenishHighlighted: UIColor {
        if let color = R.color.greenishHighlighted() {
            return color
        }
        return UIColor(hexString: "#BFE893FF")
    }
    
    class var orangeish: UIColor {
        if let color = R.color.orangeish() {
            return color
        }
        return UIColor(hexString: "#FF9500FF")
    }
    
    class var blueGrayish: UIColor {
        if let color = R.color.blueGrayish() {
            return color
        }
        return UIColor(hexString: "#AEC1D0FF")
    }
    
    class var blackish: UIColor {
        if let color = R.color.blackish() {
            return color
        }
        return UIColor(hexString: "#4A4A4AFF")
    }
    
    class var purpleish: UIColor {
        if let color = R.color.purpleish() {
            return color
        }
        return UIColor(hexString: "#9013FEFF")
    }

    class var rose: UIColor {
        return UIColor(hexString: "#FF7ACFFF")
    }
    
    class var tableViewSeparator: UIColor {
        if let color = R.color.tableViewSeparator() {
            return color
        }
        return UIColor(hexString: "#E4E3E5FF")
    }
    
    /// Creates a `color`from a given hex string
    ///
    /// - Parameter hexString: should have `#` as a prefix
    public convenience init(hexString: String) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let start = hexString.index(hexString.startIndex, offsetBy: 1)
        let hexColor = String(hexString[start...])
        
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                alpha = CGFloat(hexNumber & 0x000000ff) / 255
            }
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var hexString: String {
        let colorRef = cgColor.components
        let red = colorRef?[0] ?? 0
        let green = colorRef?[1] ?? 0
        let blue = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : green) ?? 0
        let alpha = cgColor.alpha
        
        return String(
            format: "#%02lX%02lX%02lX%02lX",
            lroundf(Float(red * 255)),
            lroundf(Float(green * 255)),
            lroundf(Float(blue * 255)),
            lroundf(Float(alpha * 255))
        )

    }
    
    func add(overlay: UIColor) -> UIColor {
        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0
        
        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0
        
        self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)
        
        let r = fgA * fgR + (1 - fgA) * bgR
        let g = fgA * fgG + (1 - fgA) * bgG
        let b = fgA * fgB + (1 - fgA) * bgB
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
