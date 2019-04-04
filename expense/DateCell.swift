//
//  InvoiceDateCell.swift
//  InVoice
//
//  Created by Georg Kitz on 14/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class DateCell: ReusableCell, ConfigurableCell {
    
    typealias ConfigType = DateItem
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pickerStackView: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    func configure(with item: DateItem) {
        titleLabel.text = item.title
        item.formattedDateObservable.bind(to: dateLabel.rx.text).disposed(by: reusableBag)
        
        pickerStackView.isHidden = !item.isExpanded
        
        datePicker.date = item.value
        datePicker.rx.date.bind(to: item.data).disposed(by: reusableBag)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        datePicker.backgroundColor = .white
    }
    
    override func setSelected(_ highlighted: Bool, animated: Bool) {
        super.setSelected(highlighted, animated: animated)
        datePicker.backgroundColor = .white
    }
}
