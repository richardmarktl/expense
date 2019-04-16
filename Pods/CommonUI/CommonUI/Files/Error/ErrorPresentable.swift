//
//  ErrorPresentable.swift
//  InVoice
//
//  Created by Georg Kitz on 05/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

public struct ErrorPresentable {
    
    /// Shows an error as alert on top of the current visibile view controller
    ///
    /// - Parameters:
    ///   - error: error we want to show, we take it's `localizedDescription` for presenting
    ///   - handler: triggered when th user presses okay
    public static func show(error: Error, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        if let controller = UIApplication.shared.topMostViewController() {
            
            let ok = PodLocalizedString("ok", comment: "")
            let information = PodLocalizedString("information", comment: "")
            
            let alert = UIAlertController(title: information, message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: ok, style: .cancel, handler: handler)
            alert.addAction(okAction)
            controller.present(alert, animated: true)
        }
    }
}
