//
//  RegisterNotificationModel.swift
//  meisterwork
//
//  Created by Georg Kitz on 06/02/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import UserNotifications
import CoreTelephony

enum APNState: Int {
    case unknown
    case accepted
    case denied
}

class RegisterNotificationModel {
    
    static let kRegisterPushNotificationsSuccess = "at_meisterwork_push_success"
    static let kRegisterPushNotificationsSuccessToken = "at_meisterwork_push_success_token"
    
    fileprivate static let kRequestedNotifications = "at_meisterwork_requested_notifications"
    
    var pushNotificationsRegistered: APNState {
        
        let isRegistered = UIApplication.shared.isRegisteredForRemoteNotifications
        let didRequest = UserDefaults.standard.bool(forKey: RegisterNotificationModel.kRequestedNotifications)
        
        if !didRequest {
            return .unknown
        } else if isRegistered {
            return .accepted
        } else {
            return .denied
        }
    }
    
    func registerForRemoteNotifications() -> Observable<APNState> {
        
        let authorizedSubject: PublishSubject<APNState> = PublishSubject()
        let pushNotificationState = pushNotificationsRegistered
        if pushNotificationState == .unknown {
            
            UserDefaults.standard.set(true, forKey: RegisterNotificationModel.kRequestedNotifications)
            UserDefaults.standard.synchronize()
        }

        // Register for Push Notifications
        let options: UNAuthorizationOptions
        if #available(iOS 12.0, *) {
             options = [.provisional, .alert, .badge, .sound]
        } else {
            options = [.alert, .badge, .sound]
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, _) in
            if granted {
                
                UIApplication.shared.registerForRemoteNotifications()
                
                authorizedSubject.onNext(.accepted)
            } else {
                authorizedSubject.onNext(.denied)
            }
        })
        
        return authorizedSubject.asObservable().observeOn(MainScheduler.instance).startWith(pushNotificationsRegistered)
    }
    
    func showSettings() -> Observable<APNState> {
        let observable = NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationDidBecomeActive).asObservable().flatMap({ [unowned self](_) -> Observable<APNState> in
            return self.registerForRemoteNotifications()
        })
        
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.shared.open(url, options: [:])
        
        return observable
    }
}
