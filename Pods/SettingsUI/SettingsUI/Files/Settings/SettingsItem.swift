//
//  SettingsItem.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//
import RxSwift
import CommonUtil

public struct SettingsItem {
    let image: UIImage
    let title: String
    let isProFeature: Bool
    let allowToAccessProFeature: Bool
    let accessibilityIdentifier: String?

    init(image: UIImage, title: String, isProFeature: Bool, allowToAccessProFeature: Bool, accessibilityIdentifier: String? = nil) {
        self.image = image
        self.title = title
        self.isProFeature = isProFeature
        self.accessibilityIdentifier = accessibilityIdentifier
        self.allowToAccessProFeature = allowToAccessProFeature
    }

    init(imageName: String, title: String) {
        guard let image = UIImage(named: imageName, in: Bundle(for: PodBundle.self), compatibleWith: nil) else {
            fatalError("The image \"\(imageName)\" is not present.")
        }
        self.init(
                image: image,
                title: PodLocalizedString(title),
                isProFeature: false,
                allowToAccessProFeature: false
        )
    }
}

public struct SubtitleItem {
    let title: String
    let subtitle: String
}

open class ProgressItem {
    let image: UIImage
    let title: String
    var isInProgress: Bool
    let progressObservable: Observable<String?>?

    init(image: UIImage, title: String, isInProgress: Bool, progressObservable: Observable<String?>? = nil) {
        self.image = image
        self.title = title
        self.isInProgress = isInProgress
        self.progressObservable = progressObservable
    }
}

