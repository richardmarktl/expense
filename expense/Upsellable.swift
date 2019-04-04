//
//  UpsellAble.swift
//  InVoice
//
//  Created by Georg Kitz on 30/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

protocol Upsellable {
    func showUpsellAlert(message: String)
}

extension Upsellable where Self: UIViewController {
    
    func showUpsellAlert(message: String) {
        
        Analytics.upsellAlertShown.logEvent()
        
        let alert = UIAlertController(title: R.string.localizable.information(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let noThankYou = UIAlertAction(title: R.string.localizable.noThankYou(), style: .cancel, handler: { _ in
            Analytics.upsellAlertNoThanks.logEvent()
        })
        alert.addAction(noThankYou)
        
        let upgrade = UIAlertAction(title: R.string.localizable.upgrade(), style: .default, handler: { _ in
            Analytics.upsellAlertUpgrade.logEvent()
            Upsell2Controller.present(in: self)
        })
        alert.addAction(upgrade)
        
        self.present(alert, animated: true)
    }
}

extension UIViewController: Upsellable {}
