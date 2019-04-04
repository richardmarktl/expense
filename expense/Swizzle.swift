//
//  Swizzle.swift
//  InVoice
//
//  Created by Georg Kitz on 15/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

let swizzling: (AnyClass, Selector, Selector) -> Void = { forClass, originalSelector, swizzledSelector in
    guard let originalMethod = class_getInstanceMethod(forClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) else {
            return
    }
    method_exchangeImplementations(originalMethod, swizzledMethod)
}
