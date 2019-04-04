//
//  SwitchCell.swift
//  InVoice
//
//  Created by Richard Marktl on 12.04.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class SwitchCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = BoolItem
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var badgeContainer: UIView!
    @IBOutlet weak var badgeView: BadgeView!

    func configure(with item: BoolItem) {
        titleLabel.text = item.title
        switchButton.isOn = item.value
        badgeContainer.isHidden = !item.isProFeature

        switchButton.rx.controlEvent(UIControlEvents.valueChanged).subscribe(onNext: { [weak self](_) in
            if let switchButton = self?.switchButton {
                item.update(switchButton.isOn)
            }
        }).disposed(by: reusableBag)

        item.data.asObservable().subscribe(onNext: { [weak self](_) in
            self?.titleLabel.text = item.title
        }).disposed(by: reusableBag)
        
        item.resetObservable.subscribe(onNext: { [weak self] (value) in
            self?.titleLabel.text = item.title
            self?.switchButton.isOn = value
        }).disposed(by: reusableBag)
    }
    
    // The stupid cell, makes every background translucent on select/highlight, we don't want that for the badge
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = badgeView.badgeColor
        super.setSelected(selected, animated: animated)
        badgeView.badgeColor = color
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = badgeView.badgeColor
        super.setHighlighted(highlighted, animated: animated)
        badgeView.badgeColor = color
    }
}
