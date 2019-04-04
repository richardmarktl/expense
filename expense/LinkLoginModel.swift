//
//  LinkLoginModel.swift
//  InVoice
//
//  Created by Georg Kitz on 10.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import EmailValidator
import CoreData

enum SpecialAccounts {
    case apple
    case demo
    
    var email: String {
        switch self {
        case .apple:
            return "john-appleseed@mac.com"
        case .demo:
            
            return "georg.kitz+demo@invoicebot.io"
        }
    }
    
    var name: String {
        switch self {
        case .apple:
            return "Apple Inc"
        case .demo:
            return "meisterwork GmbH"
        }
    }
    
    static func from(email: String) -> SpecialAccounts? {
        if email == SpecialAccounts.apple.email {
            return .apple
        } else if email == SpecialAccounts.demo.email {
            return .demo
        }
        return nil
    }
}

class LinkLoginModel {
    
    private let account: Account
    private let emailVariable: Variable<String> = Variable("")
    private let progressVariable: Variable<AccountRegisterModel.Progress> = Variable(.none)
    
    var progressObservable: Observable<AccountRegisterModel.Progress> {
        return progressVariable.asObservable()
    }
    
    var getLinkButtonEnabledObservable: Observable<Bool> {
        return Observable.combineLatest(emailVariable.asObservable(), progressVariable.asObservable()) { (email, progress) -> Bool in
            return email.count > 0 && EmailValidator.validate(email: email, allowTopLevelDomains: false, allowInternational: true) && progress == .none
        }
    }
    
    var showLoadingIndicatorObservable: Observable<Bool> {
        return progressObservable.map({ (progress) -> Bool in
            return progress != AccountRegisterModel.Progress.none
        })
    }
    
    init(context: NSManagedObjectContext) {
        account = Account.current(context: context)
    }
    
    func updateEmail(_ email: String) {
        emailVariable.value = email.removingWhitespaces()
    }
    
    func performGetLoginLink() -> Observable<Bool> {
        progressVariable.value = .login
        
        let tokenObservable: Observable<String>
        if let specialAccount = SpecialAccounts.from(email: emailVariable.value) {
            tokenObservable = AccountRequest.loginNormal(with: specialAccount.email, name: specialAccount.name, password: "f9bf9636")
        } else {
            tokenObservable = AccountRequest.login(with: emailVariable.value).do(onNext: { [weak self] (_) in
                
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
        }
        
        return tokenObservable
            .do(onNext: { [weak self] (token) in
                UserDefaults.appGroup.store(token: token)
                logger.verbose("logged in with token \(token)")
                
                self?.progressVariable.value = .loadingAccountDetails
            }).flatMap({ [unowned self](_) -> Observable<Account> in
                return AccountRequest.load(self.account, updatedAfter: nil)
            })
            .flatMap({ [unowned self](_) -> Observable<Account> in
                
                return JobDesign.migrateFromAccountIfNeeded(account: self.account, in: self.account.managedObjectContext!)
                    .flatMap({ (_) -> Observable<[Defaults]> in
                        return Defaults.migrateFromAccountIfNeeded(account: self.account, in: self.account.managedObjectContext!)
                    })
                    .flatMap({ (_) -> Observable<Account> in
                        UpdateRunner.updateRunner?.markMigrationsAsDone()
                        return Observable.just(self.account);
                    })
            })
            .flatMap({ [weak self] (account) -> Observable<Account> in
                self?.progressVariable.value = .loadingAlreadyStoredData
                return Downloader.instance!.download().takeLast(1).flatMap({ (_) -> Observable<Account> in
                    return Observable.just(account)
                })
            })
            .do(onNext: { [weak self] (account) in
                
                Analytics.updateUserInfo(for: account)
                
                try? account.managedObjectContext?.save()
                
                if UITestHelper.isUITesting {
                    AppDelegate.addMeisterworkLogoToAccount()
                    AppDelegate.addMeisterwokrSignatureToAccount()
                    AppDelegate.updateCurrentItemsToHaveCertainLanguage()
                } else {
                    // checks if the user has a logo attached to his account and downloads it
                    // stores loaded data to account
                    if let logoURL = account.logoFile, account.logoFileName == nil {
                        let filename = UUID().uuidString.lowercased()
                        
                        _ = ImageStorage.download(fromURL: logoURL, filename: filename).take(1).subscribe(onNext: { (_) in
                            account.logoFileName = filename
                            try? account.managedObjectContext?.save()
                        })
                    }
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
            })
            .map({ _ -> Bool in return true })
    }
}
