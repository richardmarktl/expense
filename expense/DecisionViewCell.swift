//
//  TaxableViewCell.swift
//  InVoice
//
//  Created by Richard Marktl on 20.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

class DecisionViewCell: ReusableCell, ActionCellProtocol {
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var action: VoiceAction? {
        didSet {
            guard let action = action as? DecisionVoiceAction else {
                return
            }
            
            yesButton.setTitle(R.string.localizable.yes(), for: .normal)
            yesButton.rx.tap.subscribe(onNext: {(_ : Void) in
                action.touched = true
                action.confirmed = true
                action.touchInputSubject?.onNext(())
            }).disposed(by: reusableBag)
            
            noButton.setTitle(R.string.localizable.no(), for: .normal)
            noButton.rx.tap.subscribe(onNext: {(_ : Void) in
                action.touched = true
                action.confirmed = false
                action.touchInputSubject?.onNext(())
            }).disposed(by: reusableBag)
        }
    }
}
