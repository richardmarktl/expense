//
//  SignatureControlCell.swift
//  InVoice
//
//  Created by Richard Marktl on 04.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class SignatureControlCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = SignatureItem
    
    @IBOutlet var newSignatureLabel: UILabel!
    
    func configure(with item: SignatureItem) {
        if SignatureViewController.hasSignatureImage() {
            newSignatureLabel.text = R.string.localizable.changeSignature()
        } else {
            newSignatureLabel.text = R.string.localizable.newSignature()
        }
    }
}

