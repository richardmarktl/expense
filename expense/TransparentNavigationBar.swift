//
//  TransparentNavigationBar.swift
//  InVoice
//
//  Created by Georg Kitz on 10.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class TransparentNavigationBar: UINavigationBar {
    override func awakeFromNib() {
        super.awakeFromNib()
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
    }
}
