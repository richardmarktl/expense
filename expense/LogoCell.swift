//
//  LogoCell.swift
//  InVoice
//
//  Created by Georg Kitz on 27.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

class LogoCell: ReusableCell, ConfigurableCell {
    
    typealias ConfigType = LogoItem
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var previewView: UIImageView!
    
    func configure(with item: LogoItem) {
        titleLabel.text = item.title
        
        previewView.isHidden = item.isLoadingLogo
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = !item.isLoadingLogo
        
        previewView.layer.cornerRadius = 4
        previewView.clipsToBounds = true
        previewView.contentMode = .scaleAspectFit
        
        item.thumbImage.asObservable().subscribe(onNext: { [weak self] (image) in
            self?.previewView.image = image
        }).disposed(by: reusableBag)
    }
}
