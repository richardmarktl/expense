//
//  AppDelegate+Routes.swift
//  InVoice
//
//  Created by Georg Kitz on 18/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import Horreum
import JLRoutes
import FacebookCore
import CoreData
import GoogleSignIn
import SwiftMoment
import FirebaseRemoteConfig

extension Notification.Name {
    static let DidReceiveValidationData = Notification.Name("DidReceiveValidationData")
}

enum ValidationData: String {
    case uid
    case token
}

extension AppDelegate {
    
    func registerRoutes() {
        
        JLRoutes.setAlwaysTreatsHostAsPathComponent(true)
        
        let authHandler = { (params: [String: Any]!) -> Bool in
            
            guard case let (uid as String, token as String) = (params["uid"], params["token"]) else {
                
                return false
            }
            
            logger.verbose("UID: \(uid), Token: \(token)")
            NotificationCenter.default.post(name: Notification.Name.DidReceiveValidationData, object: nil, userInfo: params)
            return true
        }
        
        // This handler will show the invoice or offer url. This example url opens invoice 10
        // url: invoicebot://api.invoicebot.io/bot/invoice/10
        let jobHandler = { (params: [String: Any]!) -> Bool in
            guard let jobType = params["job_type"] as? String,
                let jobIdString = params["job_id"] as? String,
                let jobId = Int64(jobIdString) else {
                return false
            }
        
            guard jobType == Path.invoice.rawValue || jobType == Path.offer.rawValue else {
                return false
            }
            
            logger.verbose("OPEN TYPE: \(jobType), ID: \(String(describing: jobId))")
            if let controller = UIApplication.shared.keyWindow?.rootViewController {
                controller.dismiss(animated: false, completion: nil)
                let job: Job?
                
                if jobType == Path.invoice.rawValue {
                    job = Invoice.object(withRemoteId: jobId, in: Horreum.instance!.mainContext)
                } else {
                    job = Offer.object(withRemoteId: jobId, in: Horreum.instance!.mainContext)
                }
                
                if let job = job {
                    let ctr = JobViewController.create(for: job)
                    controller.present(ctr, animated: true)
                }
            }
            return true
        }
        
        let overdueHandler = { (params: [String: Any]!) -> Bool in
            if let controller = UIApplication.shared.keyWindow?.rootViewController as? TabBarController {
                controller.dismiss(animated: false, completion: nil)
                controller.selectedIndex = 3
            
                guard let nCtr = controller.childViewControllers[controller.selectedIndex] as? UINavigationController else {
                    return true
                }
                nCtr.popToRootViewController(animated: false)
                
                let ctr = OverdueTomorrowInvoicesController()
                nCtr.pushViewController(ctr, animated: false)
            }
            return true
        }
        
        let monthlyRevenueHandler = { (params: [String: Any]!) -> Bool in
            if let controller = UIApplication.shared.keyWindow?.rootViewController as? TabBarController {
                controller.dismiss(animated: false, completion: nil)
                controller.selectedIndex = 3
                
                guard let nCtr = controller.childViewControllers[controller.selectedIndex] as? UINavigationController else {
                    return true
                }
                nCtr.popToRootViewController(animated: false)
            }
            return true
        }
        
        let promoCodeHandler = {(params: [String: Any]) -> Bool in
            
            guard let givenPromoCode = params["promo_code"] as? String else {
                return false
            }
            
            RemoteConfig.remoteConfig().configSettings = RemoteConfigSettings(developerModeEnabled: true)
            RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0, completionHandler: { (status, error) in
                RemoteConfig.remoteConfig().activateFetched()
                guard let currentlyActivePromoCode = RemoteConfig.remoteConfig().configValue(forKey: "promo_code").stringValue else {
                    logger.error("NO PROMO CODE GIVEN")
                    return
                }
                
                if givenPromoCode == currentlyActivePromoCode {
                    logger.verbose("PROMOCODE VALID")
                    
                    let account = Account.current()
                    let trailStarted = account.trailStartedTimestamp ?? Date()
                    let trailEnded = moment(trailStarted).add(3, TimeUnit.Months).date
                    try? account.managedObjectContext?.save()
                    
                    _ = AccountRequest.uploadTrail(for: account, started: trailStarted, ended: trailEnded).take(1).subscribe()
                    
                    Analytics.upsellPromoCodeUsed.logEvent()
                    ErrorPresentable.show(error: "You're now on a free 3 months trial. The trial will end on \(trailEnded.asString(.medium, timeStyle: .none)). Have fun 🎉🐱.")
                } else {
                    logger.error("PROMOCODE INVALID")
                    Analytics.upsellTriedToUseInvalidPromoCode.logMessage("Invalid promo code \(givenPromoCode), \(currentlyActivePromoCode)")
                    ErrorPresentable.show(error: "Your promo code is invalid 😿")
                }
            })
            
            return true
        }
        
        var endpoint = Bundle.main.infoDictionary!["API_ENDPOINT"] as? String ?? ""
        endpoint = endpoint.replacingOccurrences(of: "https://", with: "")
        endpoint = endpoint.replacingOccurrences(of: "http://", with: "")
        
        let scheme = Bundle.main.infoDictionary!["URL_SCHEME_PROTOCOL"] as? String ?? ""
        
        let authRoute = "account/auth/:uid/:token"
        let jobRoute = "bot/:job_type/:job_id"
        let overdueRoute = "bot/" + APNType.invoiceOverdue.rawValue
        let monthlyRevenueRoute = "bot/" + APNType.monthlyRevenue.rawValue
        let promoCodeRoute = "promo_code/:promo_code"
        
        [
            (authRoute, authHandler),
            (jobRoute, jobHandler),
            (overdueRoute, overdueHandler),
            (monthlyRevenueRoute, monthlyRevenueHandler),
            (promoCodeRoute, promoCodeHandler)
        ].forEach { (routeHandlerPair) in
            
            let route = routeHandlerPair.0
            let handler = routeHandlerPair.1
            
            let routeWithEndpoint = endpoint + "/" + route
            
            JLRoutes(forScheme: scheme).addRoute(route, handler: handler)
            JLRoutes(forScheme: scheme).addRoute(routeWithEndpoint, handler: handler)
            JLRoutes(forScheme: "https").addRoute(routeWithEndpoint, handler: handler)
        }
    }
    
    @objc(application:openURL:options:)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return
            JLRoutes.routeURL(url) || //Handle our own open url stuff like showing invoices
            GIDSignIn.sharedInstance()!.handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:]) || // Google Sign In
            SDKApplicationDelegate.shared.application(app, open: url, options: options) //Facebook Analytics
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        if #available(iOS 12.0, *) {
            if handle(userActivity: userActivity, intentType: CreateInvoiceIntent.self, create: JobViewController.createInvoice) {
                return true
            } else if handle(userActivity: userActivity, intentType: CreateOfferIntent.self, create: JobViewController.createOffer) {
                return true
            }
        }
        
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        return JLRoutes.routeURL(url)
    }
    
    @available(iOS 12.0, *)
    fileprivate func handle<T: InvoiceIntentCreatable>(userActivity: NSUserActivity, intentType: T.Type, create: (NSManagedObjectID) -> UIViewController) -> Bool {
        if userActivity.activityType == NSStringFromClass(T.self) {
            guard let invoiceIntent = userActivity.interaction?.intent as? T,
                let uuid = invoiceIntent.client?.identifier,
                let client = Client.object(withUuid: uuid, in: Horreum.instance!.mainContext)
                else {
                    return false
            }
            
            let ctr = create(client.objectID)
            let root = UIApplication.shared.keyWindow?.rootViewController
            root?.present(ctr, animated: true)
            return true
        }
        return false
    }
}
