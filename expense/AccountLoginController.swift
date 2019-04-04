//
//  AccountLoginController.swift
//  InVoice
//
//  Created by Georg Kitz on 17/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import SwiftRichString

extension AccountRegisterModel.Progress {
    var message: String {
        switch self {
        case .none:
            return R.string.localizable.none()
        case .login:
            return R.string.localizable.login()
        case .registerNewAccount:
            return R.string.localizable.registerNewAccount()
        case .waitingConfirmation:
            return R.string.localizable.waitingConfirmation()
        case .validating:
            return R.string.localizable.validatingLogin()
        case .loadingAccountDetails:
            return R.string.localizable.loadingAccountDetails()
        case .uploadingTrailTimestamps:
            return R.string.localizable.loginUploadingTrailInformation()
        case .loadingAlreadyStoredData:
            return R.string.localizable.loadingAlreadyStoredData()
        case .loggedIn:
            return R.string.localizable.successfullyLoggedIn()
        case .error(let message):
            return message
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .error:
            return UIColor.redish
        case .loggedIn:
            return UIColor.greenish
        default:
            return UIColor.blackish
        }
    }
}

class AccountLoginController: TableModelController<AccountRegisterModel> {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var validLabel: UILabel!
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var loginButton: ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.loginShown.logEvent()
        
        greetingLabel.text = model.name
        validLabel.attributedText = model.validUntil.set(style: StyleGroup.expireStyleGroup())
        
        model.isLoginHiddenObservable.subscribe(onNext: { [weak self](isHidden) in
            self?.progressStackView.isHidden = !isHidden
            self?.loginButton.isHidden = isHidden
        }).disposed(by: bag)
        
        model.isLoginEnabledObservable.subscribe(onNext: { [weak self](isEnabled) in
            self?.loginButton.button?.isEnabled = isEnabled
        }).disposed(by: bag)
        
        model.progress.subscribe(onNext: { [weak self] (progress) in
            Analytics.loginProgress.logMessage(progress.message)
            self?.progressLabel.text = progress.message
            self?.progressLabel.textColor = progress.textColor
        }).disposed(by: bag)
        
        loginButton.tapObservable.subscribe(onNext: { [weak self](_) in
            
            guard let `self` = self else {
                return
            }
            
            guard self.model.isEmailValid else {
                ErrorPresentable.show(error: R.string.localizable.accountEmailNotValid())
                Analytics.loginEnteredEmailNotValid.logEvent(["email": self.model.enteredEmail.asNSString])
                return
            }
            
            self.askIfEmailIsAccessible(email: self.model.enteredEmail) { (correct) in
                
                if correct {
                    Analytics.loginPerformed.logEvent()
                    self.model.performLogin()
                } else {
                    Analytics.loginEmailEnteredShouldBeCorrected.logEvent()
                }
            }
            
        }).disposed(by: bag)
        
        model.progress.filter { progress -> Bool in
            if case AccountRegisterModel.Progress.loggedIn = progress {
                return true
            }
            return false
        }
        .take(1)
        .delay(2, scheduler: MainScheduler.instance)
        .subscribe(onNext: { [weak self](_) in
            Analytics.loginDismissed.logEvent()
            self?.dismiss(animated: true)
        }).disposed(by: bag)
    }
    
    private func askIfEmailIsAccessible(email: String, completion: ( @escaping (Bool) -> Void)) {
        let message = R.string.localizable.accountEmailCorrectQuestion(email)
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

        let login = UIAlertAction(title: R.string.localizable.accountLogin(), style: .default) { (_) in
            completion(true)
        }
        let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { (_) in
            completion(false)
        }
        
        alert.addAction(login)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}
