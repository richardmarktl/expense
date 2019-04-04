//
//  UpsellFirstBaseController.swift
//  InVoice
//
//  Created by Georg Kitz on 04.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class UpsellFirstBaseController: UpsellBaseController {
    @IBOutlet weak var footerTopConstraint: NSLayoutConstraint!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        footerTopConstraint.constant = view.frame.height - 50
    }
}
