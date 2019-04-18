//
//  VisibleViewController.swift
//  InVoice
//
//  Created by Richard Marktl on 20.02.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
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
}
