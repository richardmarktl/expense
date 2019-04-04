//
//  UserDefaults+AppLaunch.swift
//  InVoice
//
//  Created by Georg Kitz on 16.04.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import SwiftMoment

enum FirstTimeUpsell: Int {
    case none
    case shouldShow
    case shown
}

extension UserDefaults {
    
    struct Static {
        static let wasUpsellPresentedOnce = "was_upsell_presented_once"
        static let appLaunches = "app_launches"
        static let appForegroundBackground = "app_foreground_background"
        static let upsellBlockLastTimeShown = "app_upsell_blocker"
        static let upsellShowFirstTimeUpsell = "app_show_first_time_upsell"
        static let upsellCancelCounter = "app_upsell_from_banner_cancel"
    }
    
    class var wasUpsellShowToday: Bool {
        guard let date = UserDefaults.standard.object(forKey: Static.upsellBlockLastTimeShown) as? Date else {
            return false
        }
        let last = moment(date)
        let now = moment()
        return last.day == now.day && last.month == now.month && last.year == now.year
    }
    
    class func storeUpsellShown(on date: Date = Date()) {
        UserDefaults.standard.set(date, forKey: Static.upsellBlockLastTimeShown)
        UserDefaults.standard.synchronize()
    }
    
    class func clearUpsellShown() {
        UserDefaults.standard.set(nil, forKey: Static.upsellBlockLastTimeShown)
        UserDefaults.standard.synchronize()
    }
    
    class func increaseUpsellCancelCounter() {
        let current = UserDefaults.standard.integer(forKey: Static.upsellCancelCounter)
        UserDefaults.standard.set(current + 1, forKey: Static.upsellCancelCounter)
        UserDefaults.standard.synchronize()
    }
    
    class func clearCancelCounter() {
        UserDefaults.standard.set(0, forKey: Static.upsellCancelCounter)
        UserDefaults.standard.synchronize()
    }
    
    class var shouldShowUpsell3AfterCancel: Bool {
        return UserDefaults.standard.integer(forKey: Static.upsellCancelCounter) >= 2
    }
    
    class var firstTimeUpsellState: FirstTimeUpsell {
        let val = UserDefaults.standard.integer(forKey: Static.upsellShowFirstTimeUpsell)
        return FirstTimeUpsell(rawValue: val) ?? .none
    }
    
    class func storeFirstTimeUpsellState(state: FirstTimeUpsell) {
        UserDefaults.standard.set(state.rawValue, forKey: Static.upsellShowFirstTimeUpsell)
        UserDefaults.standard.synchronize()
    }
    
    class var shouldShowUpsellDialog: Bool {
        // -1 is used bc we increase the counter on the first app start, but we check later in the cycle if we should show
        // the dialog, so this will always be reflected in the wrong way.
        let store = UserDefaults.standard
        let wasUpsellPresentedOnce = store.bool(forKey: Static.wasUpsellPresentedOnce)
        let launches = store.integer(forKey: Static.appLaunches)
        let backgroundForeground = store.integer(forKey: Static.appForegroundBackground)
        return (!wasUpsellPresentedOnce && launches == 1) || launches == 2 || backgroundForeground == 5
    }
    
    class func increaseAppLaunchCounterIfNeeded(_ needed: Bool) {
        if !needed {
            return
        }
        let store = UserDefaults.standard
        let launches = store.integer(forKey: Static.appLaunches) + 1
        store.set(launches, forKey: Static.appLaunches)
        store.synchronize()
    }
    
    class func increasAppBackgroundForegroundCounterIfNeeded(_ needed: Bool) {
        if !needed {
            return
        }
        let store = UserDefaults.standard
        let launches = store.integer(forKey: Static.appForegroundBackground) + 1
        store.set(launches, forKey: Static.appForegroundBackground)
        store.synchronize()
    }
    
    class func resetLaunchCounters() {
        let store = UserDefaults.standard
        store.set(true, forKey: Static.wasUpsellPresentedOnce)
        store.set(0, forKey: Static.appLaunches)
        store.set(0, forKey: Static.appForegroundBackground)
        store.synchronize()
    }
}
