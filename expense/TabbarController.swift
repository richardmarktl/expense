//
//  TabbarController.swift
//  InVoice
//
//  Created by Georg Kitz on 15/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum

class TabBarController: UITabBarController, ShowAccountLoginable {
    
    private var currentTabbarCount: Int = 0
    private var isTopViewController: Bool {
        guard let topViewController = UIApplication.shared.topMostViewController(), topViewController is TabBarController else {
            return false
        }
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTabbarItems()
        
        // This fixes the weird animation we have when we pop a controller from the navigation stack
        // https://stackoverflow.com/questions/53084806/uitabbar-items-jumping-on-back-navigation-on-ios-12-1
        if UIDevice.current.systemVersion == "12.1" {
            tabBar.isTranslucent = false
        }
        
        /*
         - show account login if needed
         - show upsell2 after first user journey
         - show block screen once a day after startup if account is expired
         - show upsell2 on every 5 taps if we aren't pro yet
         */
        
        if showAccountControllerIfNeeded() {
            return
        } else if isTopViewController && UserDefaults.firstTimeUpsellState == .shouldShow {
            UserDefaults.storeFirstTimeUpsellState(state: .shown)
            Upsell2Controller.present(in: self)
        } else if isTopViewController && CurrentAccountState.isProExpired && !UserDefaults.wasUpsellShowToday {
            UserDefaults.storeUpsellShown()
            UpsellTrialExpiredController.present(in: self)
        } else if isTopViewController && UserDefaults.shouldShowUpsell3AfterCancel {
            UserDefaults.clearCancelCounter()
            Upsell3Controller.present(in: self, mode: .showYearlyOnly)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        currentTabbarCount += 1
        
        if currentTabbarCount >= 5 && isTopViewController && !CurrentAccountState.hasPurchasedPro {
            currentTabbarCount = 0
            
            Upsell2Controller.present(in: self)
        }
    }
    
    fileprivate func setupTabbarItems() {
        tabBar.items![0].title = R.string.localizable.jobs()
        tabBar.items![0].accessibilityIdentifier = "jobs_tabbar_item"
        tabBar.items![0].accessibilityLabel = "jobs_tabbar_item"
        tabBar.items![1].title = R.string.localizable.clients()
        tabBar.items![2].title = R.string.localizable.items()
        tabBar.items![3].title = R.string.localizable.dashboard()
        tabBar.items![3].accessibilityIdentifier = "dashboard_tabbar_item"
        tabBar.items![3].accessibilityLabel = "dashboard_tabbar_item"
        tabBar.items![4].title = R.string.localizable.settings()
        tabBar.items![4].accessibilityIdentifier = "settings_tabbar_item"
        tabBar.items![4].accessibilityLabel = "settings_tabbar_item"
    }
}
