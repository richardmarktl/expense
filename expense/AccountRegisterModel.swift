//
//  AccountModel.swift
//  InVoice
//
//  Created by Georg Kitz on 17/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import EmailValidator

class AccountRegisterModel: AccountBaseModel {
    
    enum Progress: Equatable {
        case none
        case login
        case registerNewAccount
        case waitingConfirmation
        case validating
        case loggedIn
        case uploadingTrailTimestamps
        case loadingAccountDetails
        case loadingAlreadyStoredData
        case error(message: String)
        
        static func == (lhs: Progress, rhs: Progress) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none), (.login, .login), (.registerNewAccount, .registerNewAccount), (.waitingConfirmation, .waitingConfirmation),
                 (.validating, .validating), (.loggedIn, .loggedIn), (.loadingAccountDetails, .loadingAccountDetails),
                 (.uploadingTrailTimestamps, .uploadingTrailTimestamps),(.loadingAlreadyStoredData, .loadingAlreadyStoredData), (.error, .error):
                return true
            default:
                return false
            }
        }
    }
    
    var enteredEmail: String {
        return emailEntry.value.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    var enteredName: String {
        return nameEntry.value.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var isEmailValid: Bool {
        return EmailValidator.validate(email: enteredEmail, allowTopLevelDomains: false, allowInternational: true)
    }
    
    var isLoginEnabledObservable: Observable<Bool> {
        let hasNameObs = nameEntry.value.asObservable().filterNil().map { !$0.isEmpty }
        let hasEmailObs = emailEntry.value.asObservable().filterNil().map { !$0.isEmpty }
        let isNotInProgressObs = progress.map { $0 == .none }
        
        return Observable.combineLatest(hasNameObs, hasEmailObs, isNotInProgressObs, resultSelector: { (hasName, hasEmail, isNotInProgress) -> Bool in
            return hasName && hasEmail && isNotInProgress
        })
    }
    
    var isLoginHiddenObservable: Observable<Bool> {
        return progress.map { $0 != .none }
    }
    
    var shouldPerformAutoLoginObservable: Observable<Void> {
        return Observable.of(nameEntry.value.asObservable().take(1).filterNil(), emailEntry.value.asObservable().take(1).filterNil()).mapToVoid()
    }
    
    private var progressVariable: Variable<Progress> = Variable(Progress.none)
    var progress: Observable<Progress> {
        return progressVariable.asObservable()
    }
    
    required init(with context: NSManagedObjectContext) {
        super.init(with: context, sectionTitle: R.string.localizable.loginInformation())
    }
    
    required init(with context: NSManagedObjectContext, sectionTitle: String) {
        fatalError("init(with:sectionTitle:) has not been implemented")
    }
    
    func performLogin() {
        
        let email = enteredEmail
        let name = enteredName
        
        progressVariable.value = .login
        UserDefaults.appGroup.store(tokenRequestDate: Date())
        
        AccountRequest.login(with: email).catchError { [weak self] (error) -> Observable<()> in
            logger.error(error)
            
            self?.progressVariable.value = .registerNewAccount
            return AccountRequest.register(with: email, name: name)
            
        }.do(onNext: { [weak self] (_) in
            
            self?.progressVariable.value = .waitingConfirmation
            
        }).flatMap({ (_) -> Observable<Notification> in
            
            return NotificationCenter.default.rx.notification(Notification.Name.DidReceiveValidationData)
            
        }).do(onNext: { [weak self] (_) in
            
            self?.progressVariable.value = .validating
            
        }).flatMap({ (notification: Notification) -> Observable<String> in
            
            let uid = notification.userInfo?["uid"] as? String ?? ""
            let token = notification.userInfo?["token"] as? String ?? ""
            return AccountRequest.validate(uid: uid, token: token)
            
        })
        .do(onNext: { [weak self] (token) in
            UserDefaults.appGroup.store(token: token)
            logger.verbose("logged in with token \(token)")
            
            self?.progressVariable.value = .loadingAccountDetails
        }).flatMap({ [unowned self](_) -> Observable<Account> in
            
            return AccountRequest.load(self.account, updatedAfter: nil)
        })
        .flatMap({ (account) -> Observable<Account> in
            
            return JobDesign.migrateFromAccountIfNeeded(account: account, in: account.managedObjectContext!)
                .flatMap({ (_) -> Observable<[Defaults]> in
                    return Defaults.migrateFromAccountIfNeeded(account: account, in: account.managedObjectContext!)
                })
                .flatMap({ (_) -> Observable<Account> in
                    UpdateRunner.updateRunner?.markMigrationsAsDone()
                    return Observable.just(account);
                })
        })
        .subscribe(onNext: { [weak self] (account) in

            Analytics.updateUserInfo(for: account)
            try? account.managedObjectContext?.save()
            
            // checks if the user has a logo attached to his account and downloads it
            // stores loaded data to account
            if let logoURL = account.logoFile, account.logoFileName == nil {
                let filename = UUID().uuidString.lowercased()
                
                _ = ImageStorage.download(fromURL: logoURL, filename: filename).take(1).subscribe(onNext: { (_) in
                    account.logoFileName = filename
                    try? account.managedObjectContext?.save()
                })
            }
            
            self?.progressVariable.value = .loggedIn
            logger.verbose("loaded account \(account)")

        }, onError: { [weak self] (error) in

            UserDefaults.appGroup.store(tokenRequestDate: nil)
            
            self?.progressVariable.value = .error(message: error.localizedDescription)
            logger.error(error.localizedDescription)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                self?.progressVariable.value = .none
            })

        }).disposed(by: bag)
    }
}
