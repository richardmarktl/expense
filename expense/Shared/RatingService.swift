//
//  RatingService.swift
//  InVoice
//
//  Created by Georg Kitz on 14.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

struct RatingServiceConfig {
    
    let numberOfEvents: Int
    let resetOnAppUpdate: Bool
    
    static let `default` = RatingServiceConfig(numberOfEvents: 2, resetOnAppUpdate: true)
}

enum RatingResult: Int {
    case happy = 1
    case unhappy
}

class RatingService {
    
    private let config: RatingServiceConfig
    private var ratingStorage: RatingStorage {
        didSet {
            let data = try? JSONEncoder().encode(ratingStorage)
            UserDefaults.standard.setValue(data, forKey: "RatingStorage")
        }
    }
    
    private struct Static {
        static var instance: RatingService?
    }
    
    class var instance: RatingService {
        guard let instance = Static.instance else {
            fatalError()
        }
        return instance
    }
    
    var isDebug: Bool = false
    
    class func create(with config: RatingServiceConfig = .default, currentAppVersion: String) {
        Static.instance = RatingService(with: config, currentAppVersion: currentAppVersion)
    }
    
    private init(with config: RatingServiceConfig, currentAppVersion: String) {
        self.config = config
        
        if let data = UserDefaults.standard.object(forKey: "RatingStorage") as? Data,
            let ratingStorage = try? JSONDecoder().decode(RatingStorage.self, from: data) {
            
            if ratingStorage.ratingType == 2 && ratingStorage.appVersion != currentAppVersion {
                self.ratingStorage = RatingStorage(ratingType: 0, appVersion: currentAppVersion, numberOfEvents: 0)
            } else {
                self.ratingStorage = ratingStorage
            }
        
        } else {
            
            self.ratingStorage = RatingStorage(ratingType: 0, appVersion: currentAppVersion, numberOfEvents: 0)
        }
    }
    
    func increaseEventNumber() {
        self.ratingStorage = RatingStorage(ratingType: ratingStorage.ratingType, appVersion: ratingStorage.appVersion, numberOfEvents: ratingStorage.numberOfEvents + 1)
    }
    
    func shouldShowRatingDialog() -> Bool {
        return isDebug || (ratingStorage.ratingType == 0 && ratingStorage.numberOfEvents >= config.numberOfEvents)
    }
    
    func save(ratingResult: RatingResult) {
        ratingStorage = RatingStorage(ratingType: ratingResult.rawValue, appVersion: ratingStorage.appVersion, numberOfEvents: ratingStorage.numberOfEvents)
    }
}

fileprivate struct RatingStorage: Codable {
    let ratingType: Int // 0 = no, 1 = positive, 2 = negative
    let appVersion: String
    let numberOfEvents: Int
}
