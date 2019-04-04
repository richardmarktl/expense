//
//  NumberCell.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class NumberCell: ReusableCell, ConfigurableCell, InputAccessoryAble {
    
    typealias ConfigType = NumberEntry
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let validator: NumberValidator = NumberValidator()
    
    func configure(with item: NumberEntry) {
        
        titleLabel.text = item.title
        textField.text = item.textValue

        textField.rx.text.subscribe(onNext: { value in
            if let text = value, !text.isEmpty {
                item.update(with: text)
            }
        }).disposed(by: reusableBag)
        
        textField.rx.controlEvent([UIControlEvents.editingDidBegin]).subscribe(onNext: { [weak self](_) in
            self?.textField.text = nil
        }).disposed(by: reusableBag)
        
        textField.rx.controlEvent([UIControlEvents.editingDidEnd]).subscribe(onNext: { [weak self](_) in
            if let text = self?.textField.text, text.isEmpty {
                self?.textField.text = item.textValue
            }
            if item.value == NSDecimalNumber.notANumber {
                item.update(with: "0")
                self?.textField.text = item.textValue
            }
        }).disposed(by: reusableBag)
        
        registerAccessory(for: textField)
        
        validator.validatorType = item.validatorType
        textField.delegate = validator
    }
}
