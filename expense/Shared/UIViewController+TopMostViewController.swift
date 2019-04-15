//
//  VisibleViewController.swift
//  InVoice
//
//  Created by Richard Marktl on 20.02.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
    
    
    /// This method will remove view constraint that exist because of ios10 and
    /// later than ios11 save area support.
    ///
    /// - Parameter name: constraint name as string.
    func removeConstraint(by name: String) -> Void {
        if let index = view.constraints.firstIndex(where: { (constraint) -> Bool in
            return constraint.identifier == name
        }) {
            view.constraints[index].isActive = false
//            print("remove \(view.constraints[index])")
//            view.removeConstraint(view.constraints[index])
        }
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
