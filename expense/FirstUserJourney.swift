//
//  FirstUserJourney.swift
//  InVoice
//
//  Created by Georg Kitz on 10.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

enum FirstUserJourneyState: Int {
    
    case none
    case addClient
    case addItem
    case showPreview
    case ended
    
    var isInProgress: Bool {
        return self != .none && self != .ended
    }
    
    func next() -> FirstUserJourneyState {
        switch self {
        case .none: return .addClient
        case .addClient: return .addItem
        case .addItem: return .showPreview
        case .showPreview: return .ended
        case .ended: return .ended
        }
    }
    
    static func load() -> FirstUserJourneyState {
        let value = UserDefaults.standard.integer(forKey: "JourneyState")
        guard let state = FirstUserJourneyState(rawValue: value) else {
            return .none
        }
        return state
    }
    
    func save() {
        UserDefaults.standard.set(self.rawValue, forKey: "JourneyState")
        UserDefaults.standard.synchronize()
    }
}

extension FirstUserJourneyState {
    var toolTip: String {
        switch self {
        case .none: fallthrough
        case .ended: return ""
        case .addClient: return R.string.localizable.firstUserJourneyAddClient()
        case .addItem: return R.string.localizable.firstUserJourneyAddItem()
        case .showPreview: return R.string.localizable.firstUserJourneySave()
        }
    }
}
