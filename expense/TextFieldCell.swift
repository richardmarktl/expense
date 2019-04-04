//
//  TextFieldCell.swift
//  InVoice
//
//  Created by Georg Kitz on 19/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TextFieldCell: ReusableCell, ConfigurableCell, InputAccessoryAble, UITextFieldDelegate {
    typealias ConfigType = TextEntry
    
    @IBOutlet weak var textField: PlaceholderTextField!
    private var enteredTextModifier: EnteredTextModifier?
    
    func configure(with item: TextEntry) {
        textField.text = item.value.value
        textField.placeholder = item.placeholder
        textField.textContentType = item.textContentType
        textField.keyboardType = item.keyboardType
        textField.autocapitalizationType = item.autoCapitalizationType
        
        enteredTextModifier = item.enteredTextModifier
        
        textField.rx.text.bind(to: item.value).disposed(by: reusableBag)
        textField.delegate = self
        
        #if DEBUG
            textField.accessibilityIdentifier = "textfield_" + item.placeholder
        #endif
    
        item.isValidObservable.subscribe(onNext: { [weak self] (valid) in
            self?.textField.isValid = valid
            if valid {
                self?.backgroundView?.backgroundColor = UIColor.white
            } else {
                self?.backgroundView?.backgroundColor = UIColor.white
                    .add(overlay: self!.textField.floatingPlaceholderInvalidColor!.withAlphaComponent(0.10))
            }
        }).disposed(by: reusableBag)
    
        registerAccessory(for: textField)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.floatingPlaceholderColor = UIColor.main
        textField.floatingPlaceholderInvalidColor = UIColor.redish
        backgroundView = UIView()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let enteredTextModifier = enteredTextModifier {
            return enteredTextModifier(textField, range, string)
        }
        return true
    }
}
