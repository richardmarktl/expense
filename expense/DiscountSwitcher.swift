//
//  DiscountSwitcher.swift
//  InVoice
//
//  Created by Georg Kitz on 22/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class DiscountSwitcher: UIView, XibSetupable {
    
    @IBOutlet weak var switcher: UISegmentedControl!
    
    var isAbsoluteValueObservable: Observable<Bool> {
        return switcher?.rx.value.map { (idx) -> Bool in
            return idx == 0
        }.skip(1) ?? Observable.empty()
    }
    
    var isAbsoluteValue: Bool {
        set {
            switcher.selectedSegmentIndex = newValue ? 0 : 1
        }
        get {
           return switcher.selectedSegmentIndex == 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromXib()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromXib()
        setupView()
    }
    
    private func setupView() {
        let currency = CurrencyLoader.currentCurrency.symbolNative
        switcher?.setTitle(currency, forSegmentAt: 0)
    }
}
