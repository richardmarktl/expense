//
//  GreetingViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 09.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum
import RxSwift
import RxCocoa
import SwiftRichString
import GoogleSignIn

class GreetingViewController: UIViewController {
    
    @IBOutlet weak var greetingTitle: UILabel!
    @IBOutlet weak var greetingSubTitle: UILabel!
    @IBOutlet weak var continueButton: ActionButton!
    @IBOutlet weak var alreadyHaveAnAccountButton: UIButton!
    @IBOutlet weak var googleButton: ActionButton!
    @IBOutlet weak var orContinueLabel: UILabel!
    
    @IBOutlet weak var buttonStackViewContainer: UIStackView!
    @IBOutlet weak var activityIndicatorContainer: UIView!
    
    private let bag = DisposeBag()
    private let googleModel: GoogleLoginModel = {
        return GoogleLoginModel(context: Horreum.instance!.mainContext)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        
        Analytics.login2ShowGreeting.logEvent()
        self.navigationItem.backBarButtonItem = nil
        
        continueButton.tapObservable.subscribe(onNext: { [weak self] (_) in
           
            guard let `self` = self else {
                return
            }
            
           self.performSegue(withIdentifier: R.segue.greetingViewController.show_create_account, sender: nil)
        }).disposed(by: bag)
        
        alreadyHaveAnAccountButton.rx.tap.subscribe(onNext: { [weak self] in
            
            guard let `self` = self else {
                return
            }
            
            self.performSegue(withIdentifier: R.segue.greetingViewController.show_get_link, sender: nil)
            
        }).disposed(by: bag)
        
        googleButton.tapObservable.subscribe(onNext: { [weak self] (_) in

            GIDSignIn.sharedInstance()?.delegate = self?.googleModel
            GIDSignIn.sharedInstance()?.uiDelegate = self
            GIDSignIn.sharedInstance()?.signIn()
            
            Analytics.login2LoginWithGoogle.logEvent()
            
        }).disposed(by: bag)
        
        googleModel.showLoadingIndicatorObservable.subscribe(onNext: { [unowned self] (show) in
            self.buttonStackViewContainer.isHidden = show
            self.activityIndicatorContainer.isHidden = !show
        }).disposed(by: bag)
        
        googleModel.userSuccessfullyLoggedInObservable.subscribe(onNext: { [unowned self] (_) in
            self.performSegue(withIdentifier: R.segue.greetingViewController.show_create_ctr, sender: nil)
        }).disposed(by: bag)
    }
    
    private func localize() {
        greetingTitle.attributedText = R.string.localizable.loginGreeting().set(style: StyleGroup.greetingStyleGroup())
        greetingTitle.lineBreakMode = .byTruncatingTail
        greetingSubTitle.text = R.string.localizable.loginGreetingSubtitle()
        orContinueLabel.text = R.string.localizable.orContinueWith()
        
        alreadyHaveAnAccountButton.setTitle(R.string.localizable.loginAlreadyHaveAnAccount(), for: [])
        alreadyHaveAnAccountButton.accessibilityIdentifier = "already_have_an_account_button"
    }
}

extension GreetingViewController: GIDSignInUIDelegate {
}
