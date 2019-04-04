//
//  iAdTracking.swift
//  InVoice
//
//  Created by Georg Kitz on 5/30/18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import iAd
import Crashlytics

struct IAdTracking {
    
    /// checks if we already tracked the install event
    private static var wasInstallAttributed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "iad_was_install_attributed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "iad_was_install_attributed")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// checks if we already tracked the In App Purchase Event
    private static var wasInAppPurchaseAttributed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "iad_was_iap_attributed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "iad_was_iap_attributed")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// checks if we already tracked which keyword was used to get the app
    private static var wasKeywordTracked: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "iad_was_keyword_tracked")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "iad_was_keyword_tracked")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Apparantly the retrieval can fail, we wait and retry after 3secs
    private static var shouldRepeat: Bool = true
    
    //swiftlint:disable cyclomatic_complexity
    /// Performs the tracking of the iAd stuff
    static func track() {
        
        if wasInstallAttributed && wasKeywordTracked && wasInAppPurchaseAttributed {
            // we already tracked *all the things* :P
            return
        }
        
        ADClient.shared().requestAttributionDetails { (attributionDetails, error) in
            
            if let error = error {
                handleError(error)
                return
            }
            
            guard let attributionDetails = attributionDetails else {
                logParsingErrors(with: "ADClient no attribution details is empty")
                return
            }
            
            guard let userInfo = attributionDetails["Version3.1"] as? [String: NSObject] else {
                logParsingErrors(with: "ADClient wrong version")
                return
            }
            
            // in production we check that this default data that Apple returns doesn't polute our logs
            #if PROD
            guard let adGroupName = userInfo["iad-adgroup-name"] as? String else {
                logParsingErrors(with: "ADClient no or wrong AdGroup")
                return
            }
            #endif
            
            //this is madness, `true` as `string`, dafuq!
            guard let adAttribution = userInfo["iad-attribution"] as? String, adAttribution == "true" else {
                logParsingErrors(with: "ADClient no or wrong ad attribution")
                return
            }
            
            //requirements to track are met, check if we already tracked the installed event
            if !wasInstallAttributed {
                Analytics.iAdTracking.logEvent(userInfo)
                wasInstallAttributed = true
            }
            
            // yes for some reason the keyword can be empty, we still want to track the attribution
            let keyword = userInfo["iad-keyword"] as? String ?? "no-keyword"

            //requirements to track are met, check if we already tracked the keyword
            if !wasKeywordTracked {
                Analytics.iADTrackingKeyword.logEvent(["keyword": keyword.asNSString])
                wasKeywordTracked = true
            }
            
            guard let campaign = userInfo["iad-campaign-name"] as? String else {
                logParsingErrors(with: "ADClient no campaign")
                return
            }
            
            //requirements to track are met, check if we already tracked the keyword
            if !wasInAppPurchaseAttributed && StoreService.instance.hasValidReceipt {
                let details = [
                    "keyword": keyword.asNSString,
                    "campaign": campaign.asNSString,
                    "keyword-reference": (campaign + " " + keyword).asNSString
                ]
                Analytics.iAdTrackingPurchase.logEvent(details)
                wasInAppPurchaseAttributed = true
            }
        }
    }
    //swiftlint:enable cyclomatic_complexity
    
    /// Logs the errors we encounter during parsing of the userInfor
    ///
    /// - Parameter message: message we want to log
    private static func logParsingErrors(with message: String) {
        logger.error(message)
        Analytics.error.logErrorMessage(message)
    }
    
    /// Handles the error we could get whenw e request the data from the ADClient
    ///
    /// - Parameter error: the error object we want to handle
    private static func handleError(_ error: Error) {
        logger.error(error)
        Crashlytics.sharedInstance().recordError(error)
        
        if error.code == ADClientError.limitAdTracking.rawValue {
            Analytics.iAdTrackingErrorLimitedTracking.logWithErrorInformation(error)
            return
        }
        
        Analytics.iAdTrackingError.logWithErrorInformation(error)
        
        if !shouldRepeat {
            return
        }
        shouldRepeat = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            track()
        })
    }
}
