//
//  CreateAccountController.swift
//  InVoice
//
//  Created by Georg Kitz on 09.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Horreum

class CreateAccountController: UIViewController, KeyboardAppearanceListener {
    
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var continueButton: ActionButton!
    @IBOutlet weak var alreadyHaveAnAccountButton: UIButton!
    @IBOutlet weak var bottomContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let bag = DisposeBag()
    private let model = CreateAccountModel(context: Horreum.instance!.childContext())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        
        Analytics.login2ShowLinkLogin.logEvent()
        
        companyTextField.tintColor = .white
        companyTextField.delegate = self
        companyTextField.rx.text.subscribe(onNext: { [unowned self] text in
            self.model.updateCompany(text ?? "")
        }).disposed(by: bag)
        
        emailAddressTextField.tintColor = .white
        emailAddressTextField.delegate = self
        emailAddressTextField.rx.text.subscribe(onNext: { [unowned self] text in
            self.model.updateEmail(text ?? "")
        }).disposed(by: bag)
        
        continueButton.tapObservable.flatMap({ [unowned self] (_) -> Observable<Bool> in
            return self.model.performAccountCreation().catchError({ (error) -> Observable<Bool> in
                ErrorPresentable.show(error: error)
                return Observable.just(false)
            })
        })
        .filterTrue()
        .subscribe(onNext: {  (_) in
            self.performSegue(withIdentifier: R.segue.createAccountController.show_create_ctr, sender: nil)
        }).disposed(by: bag)
        
        model.continueButtonEnabledObservable.subscribe(onNext: { [unowned self] (enabled) in
            self.continueButton.button?.isEnabled = enabled
        }).disposed(by: bag)
        
        model.showLoadingIndicatorObservable.subscribe(onNext: { [unowned self] (show) in
            self.buttonContainerView.isHidden = show
            self.activityIndicatorView.isHidden = !show
        }).disposed(by: bag)
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        alreadyHaveAnAccountButton.rx.tap.subscribe(onNext: { [unowned self] (_) in
            self.performSegue(withIdentifier: R.segue.createAccountController.show_get_link, sender: nil)
        }).disposed(by: bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        registerForKeyboardEvents(rx.viewWillDisappear.mapToVoid()).subscribe(onNext: { [unowned self] (keyboardAppearance) in
            self.bottomContainerConstraint.constant = keyboardAppearance.type == .showing ? keyboardAppearance.endFrame.height : 20
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }).disposed(by: bag)
        
        if !companyTextField.isFirstResponder && !emailAddressTextField.isFirstResponder {
            companyTextField.becomeFirstResponder()
        }
    }
    
    private func localize() {
        companyTextField.placeholder = R.string.localizable.loginCompanyName()
        emailAddressTextField.placeholder = R.string.localizable.loginEnterEmailAddress()
        alreadyHaveAnAccountButton.setTitle(R.string.localizable.loginAlreadyHaveAnAccount(), for: [])
    }
}

extension CreateAccountController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if companyTextField == textField {
            emailAddressTextField.becomeFirstResponder()
            return true
        } else if emailAddressTextField == textField {
            emailAddressTextField.resignFirstResponder()
            return false
        }
        return true
    }
}
