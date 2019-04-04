//
//  SignatureNameCell.swift
//  InVoice
//
//  Created by Richard Marktl on 05.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class SignatureNameCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = SignatureItem
    
    @IBOutlet var signatureNameLabel: UILabel!
    
    func configure(with item: SignatureItem) {
        signatureNameLabel.text = item.value.signatureName
        if let name = item.value.signatureName {
            signatureNameLabel.text = name
            signatureNameLabel.textColor = .black
        } else {
            signatureNameLabel.text = R.string.localizable.noName()
            signatureNameLabel.textColor = UIColor.gray
        }
    }
}


