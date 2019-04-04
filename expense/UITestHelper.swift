//
//  AppDelegate+UITest.swift
//  Stargate
//
//  Created by Georg Kitz on 18/09/2017.
//  Copyright © 2017 DeliveryHero AG. All rights reserved.
//

import Foundation

struct UITestHelper {
    
    struct Counter {
        static var counted = 0
    }
    
    static var arguments: [String] {
        //if we need to have a specific set of keys in recording mode
        let args = ProcessInfo.processInfo.arguments
//        logger.verbose(args)
        return args
    }
    
    static var isUITesting: Bool {
        return arguments.contains("-isuitesting") || arguments.contains("-ui_testing") || arguments.contains("-FASTLANE_SNAPSHOT")
    }
}
