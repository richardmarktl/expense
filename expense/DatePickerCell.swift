//
//  DatePickerCell.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class DatePickerCell: ReusableCell, ConfigurableCell {
    
    typealias ConfigType = DatePickerItem
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    func configure(with item: DatePickerItem) {
        datePicker.date = item.value
        datePicker.rx.date.bind(to: item.data).disposed(by: reusableBag)
    }
}
