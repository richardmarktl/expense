//
//  RatingService.swift
//  SettingsUI
//
//  Created by Georg Kitz on 2019-05-10.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

public struct RatingServiceConfig {
    public let numberOfEvents: Int
    public let resetOnAppUpdate: Bool
    public static let `default` = RatingServiceConfig(numberOfEvents: 2, resetOnAppUpdate: true)
    public static let storageKey = "RatingStorage"
}

public enum RatingResult: Int {
    case happy = 1
    case unhappy
}

open class RatingService {

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

    public class var instance: RatingService {
        guard let instance = Static.instance else {
            fatalError()
        }
        return instance
    }

    public var isDebug: Bool = false

    public class func create(with config: RatingServiceConfig = .default, currentAppVersion: String) {
        Static.instance = RatingService(with: config, currentAppVersion: currentAppVersion)
    }

    private init(with config: RatingServiceConfig, currentAppVersion: String) {
        self.config = config

        if let data = UserDefaults.standard.object(forKey: RatingServiceConfig.storageKey) as? Data,
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

    public func increaseEventNumber() {
        self.ratingStorage = RatingStorage(ratingType: ratingStorage.ratingType, appVersion: ratingStorage.appVersion, numberOfEvents: ratingStorage.numberOfEvents + 1)
    }

    public func shouldShowRatingDialog() -> Bool {
        return isDebug || (ratingStorage.ratingType == 0 && ratingStorage.numberOfEvents >= config.numberOfEvents)
    }

    public func save(ratingResult: RatingResult) {
        ratingStorage = RatingStorage(ratingType: ratingResult.rawValue, appVersion: ratingStorage.appVersion, numberOfEvents: ratingStorage.numberOfEvents)
    }
}

fileprivate struct RatingStorage: Codable {
    let ratingType: Int // 0 = no, 1 = positive, 2 = negative
    let appVersion: String
    let numberOfEvents: Int
}
