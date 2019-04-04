//
//  CreateAccountModel.swift
//  InVoice
//
//  Created by Georg Kitz on 09.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import EmailValidator
import SwiftMoment

class CreateAccountModel {
    
    private let context: NSManagedObjectContext
    private let account: Account
    private let companyVariable: Variable<String> = Variable("")
    private let emailVariable: Variable<String> = Variable("")
    private let progressVariable: Variable<AccountRegisterModel.Progress> = Variable(.none)
    
    var continueButtonEnabledObservable: Observable<Bool> {
        return Observable.combineLatest(companyVariable.asObservable(), emailVariable.asObservable(), progressVariable.asObservable()) { (company, email, progress) -> Bool in
            return company.count > 0 && email.count > 0 && EmailValidator.validate(email: email, allowTopLevelDomains: false, allowInternational: true) && progress == .none
        }
    }
    
    var showLoadingIndicatorObservable: Observable<Bool> {
        return progressVariable.asObservable().map({ (progress) -> Bool in
            return progress != AccountRegisterModel.Progress.none
        })
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        account = Account.current(context: context)
    }
    
    func updateCompany(_ company: String) {
        companyVariable.value = company.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func updateEmail(_ email: String) {
        emailVariable.value = email.removingWhitespaces().trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func performAccountCreation() -> Observable<Bool> {
        let name = companyVariable.value
        let email = emailVariable.value
        let password = UUID().uuidString
        
        progressVariable.value = .registerNewAccount
        return AccountRequest.registerActive(with: emailVariable.value, name: companyVariable.value, password: password)
            .flatMap({ [unowned self] (_) -> Observable<String> in
                self.progressVariable.value = .login
                return AccountRequest.loginNormal(with: email, name: name, password: password)
                    .do(onNext: { (token) in
                        UserDefaults.appGroup.store(token: token)
                    })
            }).flatMap({ [unowned self](_) -> Observable<Void> in
                self.progressVariable.value = .uploadingTrailTimestamps
                let started = moment()
                #if PROD && !DEBUG
                let ended = started.add(7, TimeUnit.Days)
                #else
                let ended = started.add(5, TimeUnit.Minutes)
                #endif
                return AccountRequest.uploadTrail(for: self.account, started: started.date, ended: ended.date).mapToVoid()
            })
            .flatMap({ [unowned self] (_) -> Observable<Account> in
                
                self.progressVariable.value = .loadingAccountDetails
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
            .do(onNext: {[unowned self] (account) in
                
                Analytics.updateUserInfo(for: account)
                
                try account.managedObjectContext?.save()
                self.progressVariable.value = .loggedIn
                
            }, onError:{[unowned self] (error) in
                
                self.progressVariable.value = .error(message: error.localizedDescription)
                logger.error(error.localizedDescription)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    self.progressVariable.value = .none
                })
            })
            .map({ (_) in return true })
    }
}
