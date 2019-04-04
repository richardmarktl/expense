//
//  Bundle+Version.swift
//  InVoice
//
//  Created by Georg Kitz on 04.03.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
}
