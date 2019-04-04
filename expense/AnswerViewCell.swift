//
//  AnswerViewCell.swift
//  InVoice
//
//  Created by Richard Marktl on 13.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AnswerViewCell: ReusableCell, ActionCellProtocol {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var helpTextLabel: UILabel!
    
    var action: VoiceAction? {
        didSet {
            if let action = action {
                textField.text = action.voiceInput
                textField.rx.text.subscribe(onNext: { (value: String?) in
                    action.voiceInput = value
                }).disposed(by: reusableBag)
                accessibilityIdentifier = "\(action)"
                textField.accessibilityIdentifier = "\(action)_text"
                helpTextLabel.accessibilityIdentifier = "\(action)_help_text"
                helpTextLabel.text = R.string.localizable.tapToEdit()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
    }
}
