//
//  Resetable.swift
//  InVoice
//
//  Created by Richard Marktl on 26.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol Resetable {
    func shouldReset(showDialog show: Bool) -> Observable<Bool>
}

extension Resetable where Self: UIViewController {
    func shouldReset(showDialog show: Bool) -> Observable<Bool> {
        guard show == true else {
            return Observable.just(true)
        }
        
        return Observable.create({ [weak self] (observer) -> Disposable in
            let title = R.string.localizable.recipientReset()
            let message = R.string.localizable.recipientResetMessage()
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.cancel, handler: { (_) in
                observer.onNext(false)
                observer.onCompleted()
                Analytics.discardResetRecipients.logEvent()
            })
            
            let save = UIAlertAction(title: R.string.localizable.oK(), style: UIAlertActionStyle.default, handler: { (_) in
                observer.onNext(true)
                observer.onCompleted()
                Analytics.resetRecipients.logEvent()
            })
            
            alert.addAction(cancel)
            alert.addAction(save)
            
            self?.present(alert, animated: true)
            
            return Disposables.create()
        })
    }
    
}
