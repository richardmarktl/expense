//
//  AppInfo.swift
//  InVoice
//
//  Created by Georg Kitz on 22/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

struct AppInfo {
    static let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    static let build: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    static let name: String = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    
    static let pathToSubscriptionHtml = Bundle.main.path(forResource: "subscription", ofType: "html") ?? ""
    static let pathToTermsOfServiceHtml = Bundle.main.path(forResource: "terms", ofType: "html") ?? ""
    static let pathToPrivacyHtml = Bundle.main.path(forResource: "privacy", ofType: "html") ?? ""
    
    static let feedbackEmail = Bundle.main.infoDictionary?["AppFeedBackEmail"] as? String ?? "";
}
