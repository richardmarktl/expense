//
//  UIImage+Color.swift
//  meisterwork
//
//  Created by Georg Kitz on 24/04/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func imageWithColor(_ color: UIColor) -> UIImage {
        
        let size = CGSize(width: 4, height: 4)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        
        //set color
        color.set()
        
        //path
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let bezierPath = UIBezierPath(rect: frame)
        bezierPath.fill()
        
        //image
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
    }
    
    class func imageWithColor(_ color: UIColor, cornerRadius: CGFloat) -> UIImage {
        
        let size = CGSize(width: cornerRadius * 2 + 4, height: cornerRadius * 2 + 4)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        UIGraphicsGetCurrentContext()
        
        //set color
        color.set()
        
        //path
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let bezierPath = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
        bezierPath.fill()
        
        //image
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: cornerRadius + 1, left: cornerRadius + 1, bottom: cornerRadius + 1, right: cornerRadius + 1))
    }
    
    class func borderImageWithColor(_ color: UIColor, cornerRadius: CGFloat, borderWidth: CGFloat) -> UIImage {
        
        let size = CGSize(width: cornerRadius * 2 + 4, height: cornerRadius * 2 + 4)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        UIGraphicsGetCurrentContext()
        
        color.set()
        
        //path
        let halfBorderWidth:CGFloat = borderWidth / 2.0;
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height).insetBy(dx: halfBorderWidth, dy: halfBorderWidth)
        let bezierPath = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
        bezierPath.lineWidth = borderWidth
        bezierPath.stroke()
        
        //image
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: cornerRadius + 1, left: cornerRadius + 1, bottom: cornerRadius + 1, right: cornerRadius + 1))
    }
}
