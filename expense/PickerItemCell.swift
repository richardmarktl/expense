//
//  PickerItemCell.swift
//  InVoice
//
//  Created by Georg Kitz on 29.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class PickerItemCell<T: PickerItemInterface>: ReusableCell, ConfigurableCell {
    typealias ConfigType = PickerItem<T>
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var pickerStackView: UIStackView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textHintLabel: UILabel!
    @IBOutlet weak var labelContainerView: UIView!
    @IBOutlet weak var proBadge: BadgeView!
    
    func configure(with item: PickerItem<T>) {
        titleLabel.text = item.title
        valueLabel.text = item.data.value.shortDesignName
        
        labelContainerView.isHidden = item.data.value.hint == nil
        textHintLabel.text = item.data.value.hint
        
        proBadge.isHidden = StoreService.instance.hasValidReceipt
        
        pickerStackView.isHidden = !item.isExpanded
        pickerView.dataSource = item.datasource
        pickerView.delegate = item.datasource
        pickerView.selectRow(item.selectedIndex, inComponent: 0, animated: true)
        
        pickerView.rx.itemSelected.map({ item -> T in
            return T.all[item.row]
        }).bind(to: item.data).disposed(by: reusableBag)
        
        item.data.asObservable().map({ (language) -> String in
            return language.shortDesignName
        }).bind(to: valueLabel.rx.text).disposed(by: reusableBag)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let proColor = proBadge.badgeColor
        super.setHighlighted(highlighted, animated: animated)
        pickerView.backgroundColor = .white
        labelContainerView.backgroundColor = .white
        proBadge.badgeColor = proColor
    }
    
    override func setSelected(_ highlighted: Bool, animated: Bool) {
        let proColor = proBadge.badgeColor
        super.setSelected(highlighted, animated: animated)
        pickerView.backgroundColor = .white
        labelContainerView.backgroundColor = .white
        proBadge.badgeColor = proColor
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard let labelSuperView = labelContainerView.superview else {
            return view
        }
        
        if view == labelSuperView {
            return nil
        }
        return view
    }
}
