//
//  PaymentProviderViewController.swift
//  InVoice
//
//  Created by Richard Marktl on 19.04.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

class PaymentProviderViewController: UITableViewController {
    @IBOutlet var stripeSwitch: UISwitch!
    @IBOutlet var paypalSwitch: UISwitch!
    @IBOutlet var stripeLabel: UILabel!
    @IBOutlet var stripeDisabledLabel: UILabel!
    
    private let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        setupStripeButton()
        
        paypalSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe(onNext: { [unowned self] (_) in
            Analytics.paymentProviderPayPal.logEvent(["on": self.paypalSwitch.isOn.asNSNumber])
            if self.paypalSwitch.isOn {
                let ctr = PayPalSetupViewController.controller()
                ctr.cancelObservable.subscribe(onNext: { (_) in
                    self.paypalSwitch.isOn = false
                }).disposed(by: self.bag)
                self.navigationController?.pushViewController(ctr, animated: true)
            } else {
                self.disableAlert(R.string.localizable.removePayPal()).subscribe(onNext: { (cancelled) in
                    if cancelled {
                        self.paypalSwitch.isOn = true
                    } else {
                        Account.current().paypalId = nil
                        self.updateAccount()
                    }
                }).disposed(by: self.bag)
            }
        }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupStripeButton() {
        // in the case no country is available disable the stripe button, but we will show an info message
        // containing the information that an address is needed.
        let isStripeAvailable = Account.current().hasCountry
        
        title = R.string.localizable.paymentSection()
        stripeSwitch.isOn = Account.current().isStripeActivated
        paypalSwitch.isOn = Account.current().paypalId != nil
        stripeDisabledLabel.isHidden = isStripeAvailable
        stripeLabel.isHidden = !isStripeAvailable
        
        stripeSwitch.isEnabled = isStripeAvailable
        stripeSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe(onNext: { [unowned self] (_) in
            Analytics.paymentProviderStripe.logEvent(["on": self.stripeSwitch.isOn.asNSNumber])
            if self.stripeSwitch.isOn {
                let ctr = StripeSetupViewController(nibName: nil, bundle: nil)
                ctr.cancelObservable.subscribe(onNext: { (_) in
                    self.stripeSwitch.isOn = false
                }).disposed(by: self.bag)
                self.navigationController?.pushViewController(ctr, animated: true)
            } else {
                self.disableAlert(R.string.localizable.removeStripe()).subscribe(onNext: { (cancelled) in
                    if cancelled {
                        self.stripeSwitch.isOn = true
                    } else {
                        Account.current().isStripeActivated = false
                        self.updateAccount()
                    }
                }).disposed(by: self.bag)
            }
        }).disposed(by: bag)
        
    }
    
    private func disableAlert(_ message: String) -> Observable<Bool> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.cancel, handler: { (_) in
                observer.onNext(true)
                observer.onCompleted()
            })
            
            let disable = UIAlertAction(title: R.string.localizable.disable(), style: UIAlertActionStyle.default, handler: { (_) in
                observer.onNext(false)
                observer.onCompleted()
            })
            
            alert.addAction(cancel)
            alert.addAction(disable)
            
            self?.present(alert, animated: true)
            
            return Disposables.create()
        })
    }
    
    private func updateAccount() {
        _ = AccountRequest.upload(Account.current()).take(1).subscribe(onNext: { _ in
            try? Account.current().managedObjectContext?.save()
        })
    }
}
