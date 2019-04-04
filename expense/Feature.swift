//
//  Feature.swift
//  InVoice
//
//  Created by Georg Kitz on 04.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

enum Feature: Int {
    case unlimited = 1
    case backup
    case receipts
    case custom
    case onlinePayments
    case language
    
    static func all() -> [Feature] {
        return [.unlimited, .backup, .receipts, .custom, .onlinePayments, .language]
    }
}

extension Feature {
    var upsell3Title: String {
        return NSLocalizedString("upsellFeature\(rawValue)", comment: "")
    }
    
    var upsell3Description: String {
        return NSLocalizedString("upsellFeatureDescription\(rawValue)", comment: "")
    }
}
