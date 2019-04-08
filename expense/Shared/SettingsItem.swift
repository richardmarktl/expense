//
//  SettingsItem.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

struct SettingsItem {
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
}

class ProgressItem {
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

struct SubtitleItem {
    let title: String
    let subtitle: String
}
