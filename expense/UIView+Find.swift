//
//  UIView+Find.swift
//  InVoice
//
//  Created by Georg Kitz on 20/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

extension UIView {
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.flatMap { $0.superview(of: type) }
    }
    
    func subview<T>(of type: T.Type) -> T? {
        return subviews.flatMap { $0 as? T ?? $0.subview(of: type) }.first
    }
    
}
