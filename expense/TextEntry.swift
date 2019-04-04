//
//  TextEntry.swift
//  InVoice
//
//  Created by Georg Kitz on 20/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

/// Text Input Type
///
/// - single: = textfield
/// - multiline: = textview
enum TextEntryType {
    case single
    case multiline
}

typealias StringValidator = (String) -> Bool
typealias EnteredTextModifier = (UITextField, NSRange, String) -> Bool

/// Groups the cell data together
class TextEntry {
    
    private struct Static {
        static let defaultValidator: StringValidator = { _ in
            return true
        }
    }
    
    struct TextModifier {
        static let removeWithespace: EnteredTextModifier = { (textField, range, string) -> Bool in
            if (range.location == 0 && range.length == 0 && !string.isEmpty) {
                let replacementString = string.replacingOccurrences(of: " ", with: "")
                DispatchQueue.main.async {
                    textField.text = replacementString
                    // this is important since it triggers an `rx.text` update which is needed to kick validation in
                    textField.sendActions(for: .valueChanged)
                }
            }
            return true
        }
    }
    
    let bag = DisposeBag()
    
    let placeholder: String
    let value: Variable<String?>
    let cellType: TextEntryType
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let autoCapitalizationType: UITextAutocapitalizationType
    let enteredTextModifier: EnteredTextModifier?
    private let validator: StringValidator
    
    var isValidObservable: Observable<Bool> {
        return value.asObservable().filterNil().map({ [unowned self] (data) -> Bool in
            return self.validator(data)
        }).startWith(true)
    }
    
    init(placeholder: String, value: String?, cellType: TextEntryType = .single, keyboardType: UIKeyboardType = UIKeyboardType.default,
         textContentType: UITextContentType? = nil, changeObserver: AnyObserver<Void>? = nil, autoCapitalizationType: UITextAutocapitalizationType = .none,
         validator: @escaping StringValidator = Static.defaultValidator, enteredTextModifier: EnteredTextModifier? = nil) {
        
        self.placeholder = placeholder
        self.cellType = cellType
        self.value = Variable(value)
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autoCapitalizationType = autoCapitalizationType
        self.validator = validator
        self.enteredTextModifier = enteredTextModifier
        
        if let observer = changeObserver {
           self.value.asObservable().mapToVoid().subscribe(observer).disposed(by: bag)
        }
    }
}
