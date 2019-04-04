//
//  ErrorPresentable.swift
//  InVoice
//
//  Created by Georg Kitz on 05/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

struct ErrorPresentable {
    static func show(error: Error, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        if let controller = UIApplication.shared.topMostViewController() {
            let alert = UIAlertController(title: R.string.localizable.information(), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: R.string.localizable.oK(), style: .cancel, handler: handler)
            alert.addAction(okAction)
            controller.present(alert, animated: true)
        }
    }
}
