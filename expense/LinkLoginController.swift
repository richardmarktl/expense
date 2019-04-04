//
//  LinkLoginController.swift
//  InVoice
//
//  Created by Georg Kitz on 09.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import Horreum

class LinkLoginController: UIViewController, KeyboardAppearanceListener {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var emailAddressHintLabel: UILabel!
    @IBOutlet weak var getLinkButton: ActionButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomContainerConstraint: NSLayoutConstraint!
    
    private let bag = DisposeBag()
    private let model = LinkLoginModel(context: Horreum.instance!.mainContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        
        Analytics.login2ShowLinkLogin.logEvent()
        
        emailAddressTextField.tintColor = .white
        emailAddressTextField.delegate = self
        emailAddressTextField.rx.text.subscribe(onNext: { [unowned self] text in
            self.model.updateEmail(text ?? "")
        }).disposed(by: bag)
        
        getLinkButton.tapObservable.flatMap({ [unowned self] (_) -> Observable<Bool> in
            return self.model.performGetLoginLink().catchError({ (error) -> Observable<Bool> in
                ErrorPresentable.show(error: error)
                return Observable.just(false)
            })
        })
        .filterTrue()
        .subscribe(onNext: { [unowned self] (value) in
            self.performSegue(withIdentifier: R.segue.linkLoginController.show_create_ctr, sender: nil)
        }).disposed(by: bag)
        
        model.getLinkButtonEnabledObservable.subscribe(onNext: { [unowned self] (enabled) in
            self.getLinkButton.button?.isEnabled = enabled
        }).disposed(by: bag)
        
        model.showLoadingIndicatorObservable.subscribe(onNext: { (show) in
            self.getLinkButton.isHidden = show
            self.activityIndicator.isHidden = !show
        }).disposed(by: bag)
        
        model.progressObservable.filter { (progress) -> Bool in
            return progress == .waitingConfirmation
        }.subscribe(onNext: { (_) in
             ErrorPresentable.show(error: "Please open your email app and tap on the link we just sent you.")
        }).disposed(by: bag)
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        registerForKeyboardEvents(rx.viewWillDisappear.mapToVoid()).subscribe(onNext: { [unowned self] (keyboardAppearance) in
            self.bottomContainerConstraint.constant = keyboardAppearance.type == .showing ? keyboardAppearance.endFrame.height + 20 : 20
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }).disposed(by: bag)
        
        if !emailAddressTextField.isFirstResponder {
            emailAddressTextField.becomeFirstResponder()
        }
    }
    
    private func localize() {
        emailAddressTextField.placeholder = R.string.localizable.loginEnterEmailAddress()
        emailAddressHintLabel.text = R.string.localizable.loginEmailAddresHint()
    }
}

extension LinkLoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
// SEND!
        return true
    }
}
