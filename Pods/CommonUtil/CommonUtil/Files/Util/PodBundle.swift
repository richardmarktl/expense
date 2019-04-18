//
//  PodBundle.swift
//  CommonUI
//
//  Created by Georg Kitz on 16.04.19.
//  Copyright © 2019 Georg Kitz. All rights reserved.
//

import Foundation

public class PodBundle {}

public extension Bundle {
    class var podBundle: Bundle? {
        return Bundle(for: PodBundle.self)
    }
}

public func PodLocalizedString(_ key: String, comment: String) -> String {
    guard let bundle = Bundle.podBundle else {
        fatalError("PodLocalizedString - bundle not found")
    }
    return NSLocalizedString(key, bundle: bundle, comment: "")
}
