//
//  PayPalSetupViewController.swift
//  InVoice
//
//  Created by Richard Marktl on 13.04.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

class PayPalSetupViewController: DetailTableModelController<Account, PayPalModel> {
    private let cancelSubject = PublishSubject<Bool>()  // true if cancelled by the user, false if an error.
    public var cancelObservable: Observable<Bool> {
        return cancelSubject.asObservable()
    }
    
    class func controller() -> PayPalSetupViewController {
        guard let ctr = R.storyboard.settings.payPalSetupViewController() else {
            fatalError()
        }
        let oldPaypalId = Account.current().paypalId
        ctr.cancelBlock = { [weak ctr] in
            // disable the observable here, because it is called after the controller was dismissed.
            ctr?.model.paypalDisposable.dispose()
            ctr?.cancelSubject.onNext(true)
            Account.current().paypalId = oldPaypalId
        }
        ctr.dismissActionBlock = { controller in
            controller.navigationController?.popViewController(animated: true)
        }
        ctr.completionBlock = { item in
            _ = AccountRequest.upload(item).take(1).subscribe(onNext: { _ in
                try? item.managedObjectContext?.save()
            })
        }
        
        ctr.item = Account.current()
        ctr.context = ctr.item.managedObjectContext
        return ctr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton?.isHidden = true
        
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}
