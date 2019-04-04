//
//  Analytics.swift
//  InVoice
//
//  Created by Richard Marktl on 19.01.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics
import FacebookCore
import Amplitude_iOS

enum Analytics: String {
    
    // app state
    case appStarted
    case appDidBecomeActive
    case appDidEnterBackground
    case appWillEnterForeground
    case appResignActive
    case appWillTerminate
    
    // account
    case loginShown
    case loginPerformed
    case loginEnteredEmailNotValid
    case loginEmailEnteredShouldBeCorrected
    case loginDismissed
    case loginProgress
    
    // new account flow
    case login2ShowGreeting
    case login2ShowLinkLogin
    case login2ShowNewAccount
    case login2ShowCreateFirstInvoice
    case login2LoginWithGoogle
    
    // events called from the job tab
    case job
    case jobOffer
    case jobInvoice
    case jobPaid
    
    case jobAddOffer
    case jobAddInvoice
    case jobVoiceAddOffer
    case jobvoiceAddInvoice
    
    // called from the client tab
    case client
    case clientNew
    case clientFromContact
    case clientSelect
    
    // new invoice
    case addInvoicePickerClient  // open the client picker controller
    case addInvoicePickClient    // pick the client in the client picker controller
    case addInvoiceNewClient     // create a new client in the picker controller
    case addInvoiceSelectClient  // select the client in the invoice.
    case addInvoicePickerItem    // select the item picker controller
    case addInvoicePickItem      // pick the item in the item picker controller
    case addInvoiceNewOrder      // create a new order int the item picker controller
    case addInvoiceSelectOrder   // select a order in the invoice.
    
    case addAttachment
    case showAttachment
    
    case showJobDetails
    
    // changes
    case changedId
    case changedDate
    case changeLanguage
    case changeCurrency
    case changePaymentDetails
    case changeNote
    case changeDiscount
    case changeOrder
    
    case showPayments
    case markAsFullyPaid
    case addPayment
    case showPayment
    case showSignature
    
    // send events
    case actionShowPreview
    case actionSendEmail
    case actionSendEmailFailed
    case actionSendEmailWithTracking
    case actionSendEmailWithTrackingFailed
    case actionShareSheet
    case actionShareSheetIncomplete
    case actionOfferToInvoice
    case actionDuplicate
    
    case noCompanyDetailsYet

    // save events
    case saveNewInvoice
    case saveModifiedInvoice
    case saveNewOffer
    case saveModifiedOffer
    case saveNewItem
    case saveModifiedItem
    case saveNewClient
    case saveModifiedClient
    
    case cancel
    case save
    case delete
    case discard
    case saveFromAlert
    case saveTopRight
    case saveNormal
    case discardResetRecipients
    case resetRecipients
    
    // events called from the item tab
    case item
    case itemNew
    case itemSelect
    
    // events called from the report tab
    case report
    case reportOustanding
    case reportUnsent
    case reportUnseen
    case reportUnseenPro
    case reportBackup
    case reportBackupPro
    case reportOverdue
    case reportOverduePro
    case reportOverdueTomorrow
    case reportOverdueTomorrowPro
    
    // events called from the settings tab
    case settings
    case settingsBanner
    case settingsRestore
    case settingsBusiness
    case settingsTax
    case settingsPayment
    case settingsNote
    case settingsBusinessSettings
    case settingsBackup
    case settingsReadReceipt
    case settingsThemes
    case settingsPaymentProvider
    case settingsSignature
    case settingsSupport
    case settingsShare
    case settingsRate
    case settingsTT
    case settingsNewsletter
    case settingsFB
    case settingsTW
    case settingsIG
    
    case backupRestore
    case backupExport
    
    case readReceiptAskForAllowance
    case readReceiptAllowed
    case readReceiptNotAllowed
    case readReceiptShowSettings
    
    case createSignature
    
    case themeSelection
    case themeColor
    case themeLogo
    case themeLogoDelete
    case themeLogoPick
    case themeLogoChange
    case themeLogoShow
    case themePreview
    case themeShowDocumentPlaceholder
    case themeAddLanguageSet
    case themeCreateLanguageSet
    case themeEditLanguageSet
    case themeDeleteLanugageSet
    
    case ratingIncreaseSignificantUse
    case ratingDoNothingSinceUserDidNotPurchaseApp
    case ratingConditionsMetTryingToShow
    case ratingConditionsNotMetYet
    
    case paymentProviderStripe
    case paymentProviderPayPal
    
    case upsellShown
    case upsellDismissed
    case upsellTT
    case upsell2Continue
    case upsellFreeTrail
    case upsellYearly
    case upsellLifetime
    case upsellMonthly
    case upsellAlertShown
    case upsellAlertUpgrade
    case upsellAlertNoThanks
    case upsellCancelled
    case upsellFailed
    case upsellUserClosedApp
    case upsellUserTerminatedApp
    case upsellUserOpenedApp
    case upsellContinueWithoutProFeaturesShown
    case upsellContinueWithoutProFeaturesAction
    case upsellRemoteConfigDisabledIt
    case upsellTopViewControllerIsNotTabBarController
    case upsellTrialBannerTapped
    case upsellTrialExpiredCtrShown
    case upsellTrialExpiredPlans
    case upsellTrialExpiredContinue
    case upsellPurchaseViaAppStoreDirectly
    case upsellPromoCodeUsed
    case upsellTriedToUseInvalidPromoCode
    
    case accountManageSubscriptions
    
    case iAdTrackingError
    case iAdTrackingErrorLimitedTracking
    case iAdTracking
    case iAdTrackingPurchase
    case iADTrackingKeyword
    
    case subscriptionIsOutsideGracePeriod
    case tryLoadingTrailPeriod
    case trialExpired
    case trialExpiredActionTriggered
    
    case custom
    case error
    
    case ratingHappy
    case ratingUnhappy
    case ratingFeedbackCancelled
    case ratingFeedbackFailed
    case ratingFeedbackSuccess
    
    case pushProvisional
    case pushDenied
    
    func logEvent(with activity: UIActivityType?) {
        let parameters: [String: NSObject]?
        if let activityType = activity?.rawValue {
            parameters = ["type": activityType.asNSString]
        } else {
            parameters = nil
        }
        self.logEvent(parameters)
    }
    
    func logEvent(_ parameters: [String: NSObject]? = nil, shouldSendImmidiatly: Bool = false) {
        #if (arch(i386) || arch(x86_64))
            return
        #endif
        //we only want to log data when we make an appstore build, otherwise we get a lot of wrong data
        #if !(DEBUG && PROD)
            Amplitude.instance().logEvent(self.rawValue, withEventProperties: parameters)
            Answers.logCustomEvent(withName: self.rawValue, customAttributes: parameters)
            
            // wohhahhahah FB!!!! with it's fucking custom types
            var appEventParameters: AppEvent.ParametersDictionary = [:]
            parameters?.forEach({ (element) in
                let key = AppEventParameterName.custom(element.key)
                if let value = element.value as? AppEventParameterValueType {
                    appEventParameters[key] = value
                }
            })
            
            AppEventsLogger.log(self.rawValue, parameters: appEventParameters)
            if shouldSendImmidiatly {
                AppEventsLogger.flush()
                Amplitude.instance().uploadEvents()
            }
        #endif
    }
    
    func logWithErrorInformation(_ error: Error) {
        let errorInfo = [
            "errorCode": error.code.asNSNumber,
            "error": error.localizedDescription.asNSString
        ]
        logEvent(errorInfo)
    }
    
    func logErrorMessage(_ message: String) {
        logEvent(["error": message.asNSString])
    }
    
    func logMessage(_ message: String) {
        logEvent(["message": message.asNSString])
    }
    
    static func setup() {
        #if (arch(i386) || arch(x86_64))
            return
        #endif
        
        Amplitude.instance().trackingSessionEvents = true
        #if PROD && !DEBUG
            Amplitude.instance().initializeApiKey("da8c94fc6b6938608896ec7c9ad5f689")
        #else
            Amplitude.instance().initializeApiKey("af30cce6be00b1680c602520f0bc340b")
        #endif
        
        #if !(DEBUG && PROD)
            Fabric.with([Crashlytics.self, Answers.self])
        #else
            Fabric.with([Crashlytics.self])
        #endif
    }
    
    static func logPurchase(_ product: Product) {
        #if (arch(i386) || arch(x86_64))
            return
        #endif
        //we only want to log data when we make an appstore build, otherwise we get a lot of wrong data
        #if !(DEBUG && PROD)
            AppEventsLogger.log(.purchased(amount: product.product.price.doubleValue,
                                           currency: product.currencyString))
            
            Answers.logPurchase(withPrice: product.product.price,
                                currency: product.currencyString,
                                success: true,
                                itemName: product.trackingTitle,
                                itemType: "subscription",
                                itemId: product.product.productIdentifier)
            
            let revenue = AMPRevenue()
            revenue.setPrice(product.product.price)
            revenue.setProductIdentifier(product.product.productIdentifier)
            revenue.setEventProperties(["currency": product.currencyString])
            Amplitude.instance().logRevenueV2(revenue)
        #endif
    }
    
    static func updateUserInfo(for account: Account) {
        
        let userIdString = String(account.remoteId)
        AppEventsLogger.userId = userIdString

        Amplitude.instance().setUserId(userIdString)
    }
}

extension NSString: AppEventParameterValueType {
    /// An object representation of `self`, suitable for parameter value of `AppEventLoggable`.
    public var appEventParameterValue: Any {
        return self as String
    }
}
