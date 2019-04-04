//
//  JobDetailCell.swift
//  InVoice
//
//  Created by Georg Kitz on 31.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class JobDetailCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = JobDetailItem
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    func configure(with item: JobDetailItem) {
        leftLabel.text = item.title
        item.data.asObservable().bind(to: rightLabel.rx.text).disposed(by: reusableBag)
        item.data.asObservable().map { (value) -> Bool in
            return value.isEmpty
        }.subscribe(onNext: { [unowned self](value) in
            
            UIView.animate(withDuration: 0.25, animations: {
                self.arrowImageView.transform = !value ? CGAffineTransform.identity : CGAffineTransform(rotationAngle: CGFloat.pi)
            })
            
        }).disposed(by: reusableBag)
    }
}
