//
//  KeyboardAccessory.swift
//  InVoice
//
//  Created by Georg Kitz on 20/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// View that wraps keyboard accessory stuff like up/down and hide keyboard
class KeyboardAccessory: UIView, XibSetupable {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var hideKeyboardButton: UIBarButtonItem!
    @IBOutlet weak var upKeyboardButton: UIBarButtonItem!
    @IBOutlet weak var downKeyboardButton: UIBarButtonItem!
    
    var hideKeyboardObservable: Observable<Void> {
        return hideKeyboardButton.rx.tap.mapToVoid()
    }
    
    var upObservable: Observable<Void> {
        return upKeyboardButton.rx.tap.mapToVoid()
    }
    
    var downObservable: Observable<Void> {
        return downKeyboardButton.rx.tap.mapToVoid()
    }
    
    convenience init(frame: CGRect, customCenterView: UIView? = nil) {
        self.init(frame: frame)
        
        if let view = customCenterView {
            
            let barItem = UIBarButtonItem(customView: view)
            
            var items = toolbar.items
            items?.insert(barItem, at: 3)
            toolbar.items = items
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromXib()
    }
}
