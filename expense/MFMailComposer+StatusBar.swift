//
//  MFMailComposer+StatusBar.swift
//  InVoice
//
//  Created by Georg Kitz on 17.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import MessageUI
import UIKit

extension MFMailComposeViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
