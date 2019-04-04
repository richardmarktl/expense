//
//  CreateFirstInvoiceController.swift
//  InVoice
//
//  Created by Georg Kitz on 13.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import SwiftRichString
import RxSwift

class CreateFirstInvoiceController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var continueButton: ActionButton!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.login2ShowCreateFirstInvoice.logEvent()
        localise()
        
        FirstUserJourneyState.addClient.save()
        
        continueButton.tapObservable.subscribe(onNext: { [unowned self]  (_) in
            let presenter = self.presentingViewController
            self.dismiss(animated: true, completion: {
                
                if UITestHelper.isUITesting {
                    return
                }
                
                Analytics.jobAddInvoice.logEvent()
                let ctr = JobViewController.createInvoice()
                presenter?.present(ctr, animated: true)
            })
        }).disposed(by: bag)
        
        navigationItem.hidesBackButton = true
    }
    
    private func localise() {
        titleLabel.attributedText = R.string.localizable.loginCreateYourFirstInvoice().set(style: StyleGroup.greetingStyleGroup())
        continueButton.title = R.string.localizable.upsellContinue.key
    }
}
