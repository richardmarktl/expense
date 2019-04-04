//
//  CurrentAccountState.swift
//  InVoice
//
//  Created by Georg Kitz on 13.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import SwiftMoment

struct CurrentAccountState {
    
    enum Value {
        case none
        case freeTrail
        case promo
        case trialExpired
        case pro
    }
    
    static var value: CurrentAccountState.Value {
    
        if StoreService.instance.hasValidReceipt {
            return .pro
        }
        
        guard let _ = Account.current().trailEndedTimestamp else {
            return .none
        }
        
        if let started = Account.current().trailStartedTimestamp?.asMoment, let ended = Account.current().trailEndedTimestamp?.asMoment, (ended - started).days > 7 {
                return .promo
        }
        
        if Date().timeIntervalSince1970 < Account.current().trailEndedTimestamp!.timeIntervalSince1970 {
            return .freeTrail
        }
        return .trialExpired
    }
    
    static var freeAccountExpireDate: Date {
        return Account.current().trailEndedTimestamp!
    }
    
    static var isPro: Bool {
        let currentValue = value
        return currentValue == .freeTrail || currentValue == .pro || currentValue == .promo
    }
    
    static var isProExpired: Bool {
        return value == .trialExpired
    }
    
    static var hasPurchasedPro: Bool {
        return value == .pro || value == .promo
    }
}
