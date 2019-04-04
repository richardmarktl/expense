//
//  SettingsProgressCell.swift
//  InVoice
//
//  Created by Georg Kitz on 24/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class ProgressCell: ReusableCell, ConfigurableCell {
    
    typealias ConfigType = ProgressItem
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func configure(with item: ProgressItem) {
        itemImageView.image = item.image
        itemLabel.text = item.title
        activityIndicator.isHidden = !item.isInProgress
        
        item.progressObservable?.subscribe(onNext: { [weak self](value) in
            self?.progressLabel.isHidden = value == nil
            self?.progressLabel.text = value
        }).disposed(by: reusableBag)
    }
}
