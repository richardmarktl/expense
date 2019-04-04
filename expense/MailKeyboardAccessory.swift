//
// Created by Richard Marktl on 01.02.18.
// Copyright (c) 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

class MailKeyboardAccessory: UIView, XibSetupable {
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var hideKeyboardButton: UIBarButtonItem!

    var hideKeyboardObservable: Observable<Void> {
        return hideKeyboardButton.rx.tap.mapToVoid()
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
