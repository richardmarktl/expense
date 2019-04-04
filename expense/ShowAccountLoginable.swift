//
//  ShowAccountLoginable.swift
//  InVoice
//
//  Created by Georg Kitz on 18/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum

protocol ShowAccountLoginable {
    func showAccountControllerIfNeeded() -> Bool
}

struct ShowAccountStatic {
    static var count: Int = 0
}

extension ShowAccountLoginable where Self: UIViewController {
    
    func showAccountControllerIfNeeded() -> Bool {
        
        if Account.current().remoteId == 0 && ShowAccountStatic.count == 0 {
            guard let ctr = R.storyboard.login.instantiateInitialViewController() else {
                return false
            }
            
            ctr.modalPresentationStyle = UIModalPresentationStyle.formSheet
            
            ShowAccountStatic.count = 1
            present(ctr, animated: true)
            return true
        }
        
        if StoreService.instance.hasValidReceipt && !UserDefaults.appGroup.hasToken() {
            guard let ctr = R.storyboard.settings.accountLoginController() else {
                return false
            }
            
            ctr.context = Horreum.instance!.mainContext
            if let presentingCtr = self.presentingViewController {
                presentingCtr.present(ctr, animated: true)
            } else {
                present(ctr, animated: true)
            }
            return true
        }
        
        return false
    }
}
