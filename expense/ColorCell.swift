//
//  ColorCell.swift
//  InVoice
//
//  Created by Georg Kitz on 05/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class ColorCell: ReusableCell, ConfigurableCell {
    
    typealias ConfigType = ColorItem
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorView: UIImageView!
    
    func configure(with item: ColorItem) {
        titleLabel.text = item.title
        
        item.data.asObservable().subscribe(onNext: { [weak self] (color) in
            self?.colorView.image = UIImage.imageWithColor(color, cornerRadius: 4)
        }).disposed(by: reusableBag)
    }
}
