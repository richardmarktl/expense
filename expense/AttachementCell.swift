//
//  AttachementCell.swift
//  InVoice
//
//  Created by Georg Kitz on 26/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class AttachementCell: ReusableCell, ConfigurableCell {
    
    typealias ConfigType = AttachmentItem
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    func configure(with item: AttachmentItem) {
        
        titleLabel.text = item.title
        
        indicatorView.startAnimating()
        thumbImageView.isHidden = true
        indicatorView.isHidden = false
        
        thumbImageView.layer.cornerRadius = 4
        thumbImageView.clipsToBounds = true
        
        item.thumbImage.subscribe(onNext: { [weak self] (image) in
            self?.thumbImageView.image = image
            self?.thumbImageView.isHidden = false
            self?.indicatorView.isHidden = true
        }).disposed(by: reusableBag)
    }
}
