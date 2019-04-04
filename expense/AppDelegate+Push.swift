//
//  UIApplication+Push.swift
//  InVoice
//
//  Created by Georg Kitz on 02/02/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum
import UserNotifications
import FirebaseMessaging

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func registerMessagingDelegate() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        logger.verbose(fcmToken)
        _ = DeviceRequest.upload(token: fcmToken, context: Horreum.instance!.mainContext).subscribe()
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        logger.debug(userInfo)
        
        // Change this to your preferred presentation option
        
        _ = AppDelegatePushHandler.handle(userInfo: userInfo).take(1).subscribe({ _ in
            completionHandler([])
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Print full message.
        logger.debug(userInfo)
        _ = AppDelegatePushHandler.handle(userInfo: userInfo).take(1).subscribe({ _ in
            completionHandler()
        })
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

        // Print full message.
        logger.debug(userInfo)
        _ = AppDelegatePushHandler.handle(userInfo: userInfo).take(1).subscribe()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Print full message.
        logger.debug(userInfo)
        
        _ = AppDelegatePushHandler.handle(userInfo: userInfo).take(1).subscribe(onNext: {
            completionHandler(UIBackgroundFetchResult.newData)
        }, onError: { _ in
            completionHandler(UIBackgroundFetchResult.failed)
        })
    }
}
