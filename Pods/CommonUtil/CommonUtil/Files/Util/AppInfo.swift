//
//  AppInfo.swift
//  CommonUtil
//
// Created by Richard Marktl on 2019-05-10.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation

public func infoDictionary(of bundle: Bundle, key: String, default value: String = "") -> String {
    return bundle.infoDictionary?[key] as? String ?? value
}

public func mainInfoDictionary(key: String, default value: String = "") -> String {
    return infoDictionary(of: Bundle.main, key: key, default: value)
}

public struct AppInfo {
    public static let version: String = mainInfoDictionary(key: "CFBundleShortVersionString", default: "0.0.0")
    public static let build: String = mainInfoDictionary(key: "CFBundleVersion")
    public static let name: String = mainInfoDictionary(key: "CFBundleName")

    public static let pathToSubscriptionHtml = Bundle.main.path(forResource: "subscription", ofType: "html") ?? ""
    public static let pathToTermsOfServiceHtml = Bundle.main.path(forResource: "terms", ofType: "html") ?? ""
    public static let pathToPrivacyHtml = Bundle.main.path(forResource: "privacy", ofType: "html") ?? ""

    public static let feedbackEmail = mainInfoDictionary(key: "AppFeedBackEmail");
    public static let facebookURL = mainInfoDictionary(key: "AppFaceBookURL");
    public static let twitterURL = mainInfoDictionary(key: "AppTwitterURL");
    public static let instagramURL = mainInfoDictionary(key: "AppInstagramURL");
}
