//
//  AppInfo.swift
//  InVoice
//
//  Created by Georg Kitz on 22/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

struct Appinfo {
    static let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    static let build: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    static let name: String = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
}
