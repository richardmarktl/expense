//
//  AppDelegate.swift
//  InVoice
//
//  Created by Georg Kitz on 09/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum
import StoreKit
import FirebaseCore
import FirebaseRemoteConfig
import Crashlytics
import CoreData
import UserNotifications
import Kvitto
import RxSwift
import FacebookCore
import Intents
import GoogleSignIn
import FBSDKCoreKit.FBSDKAppLinkUtility

#if STATUSBAR
//import SimulatorStatusMagic
//import ShowTime
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deletedItemUploader: DeletedItemUploader?
    var fuckupResolver: FuckupResolver?
    var notUploadedItemsUploader: NotUploadedDataManager?
    var stateCheckCtx: NSManagedObjectContext!
    var migrationsRunner: UpdateRunner = UpdateRunner.create()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        
        Analytics.setup()
        setupLogger()
        
        /** FB BEGIN, WTF DOES ALL THIS SHIT ACTUALLY DO??! **/
        FBSDKAppLinkUtility.fetchDeferredAppLink { (url, error) in
            logger.debug("url: \(String(describing: url)), error: \(String(describing: error))")
        }
        AppEventsLogger.activate(application)
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        /** FB END **/
        IAdTracking.track()
        
        setupDatabase()
        registerRoutes()
        
        UserDefaults.standard.migrate(to: UserDefaults.appGroup)
        AppAppearance.updateAppearance()
        
        DefaultData.insertDefaultData(in: Horreum.instance!.mainContext, debug: false)
        
        if UITestHelper.isUITesting {
            #if STATUSBAR
            AppDelegate.addTouchesToVideo()
//            SDStatusBarManager.sharedInstance().enableOverrides()
            #endif
        }
        
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        
        StoreService.instance.loadProducts()
        _ = StoreService.instance.productsObservable.skip(1).take(1).subscribe(onNext: { (products) in
            logger.debug(products)
        })
        
        if UserDefaults.lastUploadDate == nil {
            UserDefaults.store(lastUpload: Date())
        }
        
        deletedItemUploader = DeletedItemUploader()
        
        let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ctx.parent = Horreum.instance!.mainContext
        
        notUploadedItemsUploader = NotUploadedDataManager(context: ctx, updatedClosure: { (uploaded) in
            logger.verbose("Uploaded: \(uploaded)")
        })
                
        fuckupResolver = FuckupResolver(context: ctx)
        
        registerMessagingDelegate()
        
        stateCheckCtx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        stateCheckCtx.parent = Horreum.instance!.mainContext
        
        _ = JobStateChecker.checkJobStates(in: stateCheckCtx).subscribe(onNext: { [unowned self](_) in
            //swiftlint:disable force_try
            try! self.stateCheckCtx.save()
            //swiftlint:enable force_try
        })
        
        loadLogoIntoLocalStorage()
        
        // we don't want to interfere with notifications or something like that
        let counterIncreaseNeeded = !StoreService.instance.hasValidReceipt
        UserDefaults.increaseAppLaunchCounterIfNeeded(counterIncreaseNeeded)
        
        Analytics.appStarted.logEvent(["isPro": StoreService.instance.hasValidReceipt.asNSNumber])
        
        migrationsRunner.registerMigration(for: "1.7.0") { () -> Observable<Void> in
            let account = Account.current()
            return JobDesign.migrateFromAccountIfNeeded(account: account, in: account.managedObjectContext!)
                .take(1)
                .mapToVoid()
                .do(onNext: { (_) in
                    try? account.managedObjectContext?.save()
                })
        }
        
        migrationsRunner.registerMigration(for: "1.8.0") { () -> Observable<Void> in
            let account = Account.current()
            return Defaults.migrateFromAccountIfNeeded(account: account, in: account.managedObjectContext!)
                .take(1)
                .mapToVoid()
                .do(onNext: { (_) in
                    try? account.managedObjectContext?.save()
                })
        }
        
        migrationsRunner.registerMigration(for: "1.8.1") { () -> Observable<Void> in
            let context = Horreum.instance!.childContext()
            return Migrate181.migrate(context: context)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            MigrationItemAndOrderTitle.migrate(in: Horreum.instance!.mainContext)
            _ = CurrencyLoader.allCurrencies
            _ = AccountRequest.uploadProState().take(1).subscribe()
            RatingService.create(currentAppVersion: Bundle.main.appVersion)
            #if DEBUG
            RatingService.instance.isDebug = true
            #endif
            
            let account = Account.current()
            if account.remoteId > 0 {
                
                if account.trailEndedTimestamp == nil {
                    Analytics.tryLoadingTrailPeriod.logEvent()
                    _ = AccountRequest.load(account, updatedAfter: nil).take(1).subscribe(onNext: { (account) in
                        try? account.managedObjectContext?.save()
                    })
                    
                    Analytics.updateUserInfo(for: account)
                }
                
                self.migrationsRunner.runMigrations()
            }
            
            _ = self.fuckupResolver?.resolve().take(1).subscribe()
        }
        
        registerForProvisionalPushNotificationsIfNeeded()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for
//        certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers,
//        and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if UITestHelper.isUITesting {
            showTestNotifications(interval: 1.0)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        #if !(DEBUG && PROD)
            AppEventsLogger.activate(application)
        #endif
        
        if CurrentAccountState.value == .trialExpired {
            Analytics.trialExpired.logEvent()
        }
        
        logProvisionalPushAccessWithdrawnIfNeeded()
        
        _ = migrationsRunner.migrationObservable.filter { (migrationState) -> Bool in
            return migrationState == MigrationState.done
        }.take(1).subscribe(onNext: { (_) in
            logger.verbose("Migrations done!")
            _ = Downloader.instance!.download().take(1).subscribe(onNext: { (_) in
                logger.debug("Synched all changed data!");
            })
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        StoreService.instance.removeAsObserverFromPaymentQueue()
        Analytics.appWillTerminate.logEvent(["isPro": StoreService.instance.hasValidReceipt.asNSNumber])
        UserDefaults.clearUpsellShown()
    }
    
    private func logProvisionalPushAccessWithdrawnIfNeeded() {
        if UserDefaults.appGroup.bool(forKey: "provisionalPushAccessAllowed") {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .denied {
                    UserDefaults.appGroup.set(false, forKey: "provisionalPushAccessAllowed")
                    Analytics.pushDenied.logEvent()
                }
            }
        }
    }
    
    private func registerForProvisionalPushNotificationsIfNeeded() {
        if #available(iOS 12.0, *) {
            let registerAPNModel = RegisterNotificationModel()
            if registerAPNModel.pushNotificationsRegistered == .accepted {
                return
            }
            _ = registerAPNModel.registerForRemoteNotifications().skip(1).take(1).subscribe(onNext: { (apnState) in
                Analytics.pushProvisional.logEvent(["state": apnState.rawValue.asNSNumber])
                UserDefaults.appGroup.set(true, forKey: "provisionalPushAccessAllowed")
                logger.debug("Provisional Registert of APN \(apnState)")
            })
        }
    }
    
    private func loadLogoIntoLocalStorage() {
        let account = Account.current()
        if let filename = account.logoFileName {
            _ = ImageStorage.loadImage(for: filename).take(1).subscribe()
        }
    }
    
    private func setupDatabase() {
        if UITestHelper.isUITesting {
            UserDefaults.appGroup.clearToken()
            authorizeTestNotifications(showOnceAuthorized: false)
            Horreum.creatDatabaseForTesting()
            #if STATUSBAR && (arch(i386) || arch(x86_64))
//                SDStatusBarManager.sharedInstance().enableOverrides()
            #endif
        } else {
            Horreum.createDatabaseForApp()
        }
    }
    
    public static func addMeisterworkLogoToAccount() {
        if let logoWhite = R.image.logo_white() {
            _ = ImageStorage.storeImage(originalImage: logoWhite, filename: "logo_white").take(1).subscribe(onNext: { (logoStorageItem) in
                let account = Account.current()
                account.logoPath = logoStorageItem.imagePath
                account.logoThumbPath = logoStorageItem.thumbnailPath
                account.logoFileName = logoStorageItem.filename
                
                try? account.managedObjectContext?.save()
            })
        }
    }
    
    public static func addMeisterwokrSignatureToAccount() {
        if let logoWhite = R.image.default_signature() {
            let account = Account.current()
            account.signatureName = "Georg Kitz"
            
            let signatureFileName = SignatureViewController.defaultSignatureFileName
            _ = ImageStorage.storeImage(originalImage: logoWhite, filename: signatureFileName).take(1).subscribe()
        }
    }
    
    public static func addMaxMustermannSignatureToFirstInvoice() {
        if let invoice = Invoice.allObjects(context: Horreum.instance!.mainContext).first, let recipient = invoice.recipientsTyped.first, invoice.recipientsTyped.count > 1 {
            Horreum.instance?.mainContext.delete(recipient)
        }
        if let signature = R.image.max_mustermann() {
            if let recipient = Invoice.allObjects(context: Horreum.instance!.mainContext).first?.recipientsTyped.first,
                let signaturePath = recipient.signatureImagePath {
                _ = ImageStorage.storeImage(originalImage: signature, filename: signaturePath).take(1).subscribe(onNext: { (imageItem) in
                    try? Horreum.instance!.mainContext.save()
                })
            }
        }
    }
    
    public static func updateCurrentItemsToHaveCertainLanguage() {
        
        let client = Client.allObjects(context: Horreum.instance!.mainContext).first
        client?.name = R.string.localizable.clientName()
        client?.address = R.string.localizable.clientAddress()
        client?.email = R.string.localizable.clientEmail()
        client?.phone = R.string.localizable.clientPhone()
        client?.taxId = R.string.localizable.clientTaxId()
        
        let invoice = Invoice.allObjects(context: Horreum.instance!.mainContext).first
        invoice?.number = R.string.localizable.inv() + "0001"
        invoice?.language = Locale.current.languageCode
        invoice?.currency = Locale.current.currencyCode
        invoice?.update(from: client)
        invoice?.paymentDetails = R.string.localizable.sampleBankDetails()
        
        let recipient = invoice?.recipientsTyped.asSorted().last
        recipient?.signatureName = client?.name
        recipient?.name = client?.name
        if let signaturePath = recipient?.signatureImagePath,
            let imageName = recipient?.name?.lowercased().replacingOccurrences(of: " ", with: "_"),
            let signature = UIImage(named: imageName) {
            _ = ImageStorage.storeImage(originalImage: signature, filename: signaturePath).take(1).subscribe(onNext: { (_) in
            })
        }
        
        let orderInfos: [(String, String)] = [
            (R.string.localizable.itemTitle(), R.string.localizable.itemDescription()),
            (R.string.localizable.itemTitle1(), R.string.localizable.itemDescription1()),
            (R.string.localizable.itemTitle2(), R.string.localizable.itemDescription2()),
            (R.string.localizable.itemTitle3(), R.string.localizable.itemDescription3()),
        ]
        invoice?.ordersTyped.asSorted().enumerated().forEach({ (item) in
            item.element.title = orderInfos[item.offset].0
            item.element.itemDescription = orderInfos[item.offset].1
        })
    }
    
    public static func addTouchesToVideo() {
        #if STATUSBAR
//            ShowTime.enabled = .always
//            ShowTime.fillColor = UIColor(hexString: "#D8D8D8FF").withAlphaComponent(0.5)
//            ShowTime.strokeColor = UIColor(hexString: "#D8D8D8FF")
        #endif
    }
    
    private func authorizeTestNotifications(showOnceAuthorized: Bool = true) {
        let options: UNAuthorizationOptions = [.alert, .sound]
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: options) { [weak self](success, _) in
            
            if success && showOnceAuthorized {
                self?.showTestNotifications(interval: 5.0)
            }
        }
    }
    
    private func showTestNotifications(interval: TimeInterval) {
        let name = R.string.localizable.clientName().sampleHintReplaced
        
        let opened = UNMutableNotificationContent()
        opened.title = R.string.localizable.invoiceOpened()
        opened.body = R.string.localizable.invoiceOpenedMessage(name, "INV2018028")
        
        let downloaded = UNMutableNotificationContent()
        downloaded.title = R.string.localizable.invoiceDownloaded()
        downloaded.body = R.string.localizable.invoiceDownloadedMessage(name, "INV2018028")
        
        let paid = UNMutableNotificationContent()
        paid.title = R.string.localizable.invoicePaid()
        paid.body = R.string.localizable.invoicePaidMessage(name, "INV2018028")
        
        let openedRequest = UNNotificationRequest(identifier: "opened", content: opened, trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false))
        let downloadedRequest = UNNotificationRequest(identifier: "downloaded", content: downloaded, trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false))
        let paidRequest = UNNotificationRequest(identifier: "paid", content: paid, trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false))
        
        let center = UNUserNotificationCenter.current()
        center.add(openedRequest)
        center.add(downloadedRequest)
        center.add(paidRequest)
    }
}
