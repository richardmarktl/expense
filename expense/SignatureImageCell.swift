//
//  SignatureImageCell.swift
//  InVoice
//
//  Created by Richard Marktl on 04.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class SignatureImageCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = SignatureItem
    
    @IBOutlet var signatureImageView: UIImageView!
    @IBOutlet var noSignatureLabel: UILabel!

    func configure(with item: SignatureItem) {
        signatureImageView.isHidden = !item.hasSignature
        noSignatureLabel.isHidden = !signatureImageView.isHidden
        
        item.signatureImage.subscribe(onNext: { [weak self] (image) in
            self?.signatureImageView.image = image
        }).disposed(by: reusableBag)
    }
}

