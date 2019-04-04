//
//  GreetingModel.swift
//  InVoice
//
//  Created by Georg Kitz on 17.11.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import GoogleSignIn
import CoreData
import SwiftMoment
import Horreum
import Crashlytics

class GoogleLoginModel: NSObject, GIDSignInDelegate {
    private let account: Account
    private let progressVariable: Variable<AccountRegisterModel.Progress> = Variable(AccountRegisterModel.Progress.none)
    
    var progress: Observable<AccountRegisterModel.Progress> {
        return progressVariable.asObservable()
    }
    
    var showLoadingIndicatorObservable: Observable<Bool> {
        return progressVariable.asObservable().map({ (progress) -> Bool in
            return progress != AccountRegisterModel.Progress.none
        })
    }
    
    var userSuccessfullyLoggedInObservable: Observable<Void> {
        return progressVariable.asObservable().filter({ (progress) -> Bool in
            return progress == AccountRegisterModel.Progress.loggedIn
        }).mapToVoid()
    }
    
    init(context: NSManagedObjectContext) {
        account = Account.current(context: context)
        super.init()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser?, withError error: Error?) {
        // if cancel is pressed we get an error with -5
        logger.debug("Logged in")
        
        if let error = error {
            logger.error("An error occured: \(error)")
            Crashlytics.sharedInstance().recordError(error)
            return
        }
        
        guard let user = user else {
            logger.error("Google User is nil")
            Crashlytics.sharedInstance().recordError("Google User is nil")
            return
        }
        
        guard let name = user.profile.name, let email = user.profile.email, let password = ("invoicebot-google" + email).sha256AsBase64 else {
            logger.error("Couldn't create password for google")
            Crashlytics.sharedInstance().recordError("Couldn't create password for google")
            return
        }
        
        _ = performAccountLogin(email: email, name: name, password: password).take(1).subscribe()
    }
    
    private func performAccountLogin(email: String, name: String, password: String) -> Observable<Account> {
        
        // - try to register
        // -- if it fails, try to login
        // --- if it fails stop
        // -- load account data
        // -- set trail data if needed (only for new accounts)
        
        progressVariable.value = .registerNewAccount
        return AccountRequest.registerActive(with: email, name: name, password: password)
            .catchErrorJustReturn(()) // register fails, we may already have an account with that email, let's try to login with the credentials
            .flatMap({ [unowned self] (_) -> Observable<String> in
                self.progressVariable.value = .login
                return AccountRequest.loginNormal(with: email, name: name, password: password)
                    .do(onNext: { (token) in
                        UserDefaults.appGroup.store(token: token)
                    })
            }).flatMap({ [unowned self] (_) -> Observable<Account> in
                
                self.progressVariable.value = .loadingAccountDetails
                return AccountRequest.load(self.account, updatedAfter: nil)
                    .flatMap({ [unowned self] (account) -> Observable<Account> in
                        if account.trailStartedTimestamp == nil || account.trailEndedTimestamp == nil {
                            self.progressVariable.value = .uploadingTrailTimestamps
                            let started = moment()
                            #if PROD && !DEBUG
                            let ended = started.add(7, TimeUnit.Days)
                            #else
                            let ended = started.add(5, TimeUnit.Minutes)
                            #endif
                            return AccountRequest.uploadTrail(for: account, started: started.date, ended: ended.date)
                        }
                        return Observable.just(account)
                    })
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
            .flatMap({ [weak self] (account) -> Observable<Account> in
                self?.progressVariable.value = .loadingAlreadyStoredData
                return Downloader.instance!.download().takeLast(1).flatMap({ (_) -> Observable<Account> in
                    return Observable.just(account)
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
    }
    
}
