//
//  UIApplication+TopMost.swift
//  CommonUI
//
//  Created by Georg Kitz on 16.04.19.
//  Copyright © 2019 Georg Kitz. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    /// Returns the top most viewcontroller presented from the `rootController`
    ///
    /// - Returns: possible controller that is presented on top
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
