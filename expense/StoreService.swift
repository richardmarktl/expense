//
//  StoreService.swift
//  InVoice
//
//  Created by Georg Kitz on 03/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import StoreKit
import RxStoreKit
import RxSwift
import Kvitto
import SwiftMoment

enum StoreServiceError: String, Error {
    case receiptExpired
    case neverHadASubscription
    case invalidSubscription
}

extension StoreServiceError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

private var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.formatterBehavior = .behavior10_4
    
    return formatter
}()

struct Purchase {
    let product: Product
    let success: Bool
}

struct Product {
    
    let product: SKProduct
    let periodPrice: String
    let monthlyPrice: String
    let isMonthBasedPeriod: Bool
    let hasTrail: Bool
    let currencyString: String
    let period: Int //basically months
    
    var trackingTitle: String {
        if isMonthBasedPeriod {
            return "monthly"
        }
        return "yearly"
    }
    
    init(with product: SKProduct) {
        self.product = product
        
        if formatter.locale != self.product.priceLocale {
            formatter.locale = self.product.priceLocale
        }
        
        currencyString = product.priceLocale.currencyCode ?? "USD"
        
        periodPrice = formatter.string(from: product.price) ?? "\(product.price)"
        if product.productIdentifier == StoreService.ProductIndentifiers.oneMonth {
            monthlyPrice = formatter.string(from: product.price) ?? "\(product.price)"
            isMonthBasedPeriod = true
            hasTrail = true
            period = 1
        } else if product.productIdentifier == StoreService.ProductIndentifiers.oneMonthNoTrail {
            monthlyPrice = formatter.string(from: product.price) ?? "\(product.price)"
            isMonthBasedPeriod = true
            hasTrail = false
            period = 1
        } else if product.productIdentifier == StoreService.ProductIndentifiers.twoMonths {
            monthlyPrice = formatter.string(from: product.price / 2) ?? "\(product.price)"
            isMonthBasedPeriod = true
            hasTrail = true
            period = 2
        } else if product.productIdentifier == StoreService.ProductIndentifiers.lifetime {
            monthlyPrice = formatter.string(from: product.price / 36) ?? "\(product.price)"
            isMonthBasedPeriod = false
            hasTrail = false
            period = 36
        } else {
            monthlyPrice = formatter.string(from: product.price / 12) ?? "\(product.price)"
            isMonthBasedPeriod = false
            hasTrail = false
            period = 12
        }
    }
}

class StoreService: NSObject {
    
    // MARK: Singleton
    struct Static {
        static var shouldOverrideSettings: Bool = false
        #if PROD
        static let itcSecret = "c5ba6fb1675943e79478c6d25ff2169b"
        #else
        static let itcSecret = "04886d4832f14c219b420e4485d99998"
        #endif
    }
    
    static let instance: StoreService = StoreService()
    
    // MARK: Properties
    struct ProductIndentifiers {
        static let oneMonth = Bundle.main.bundleIdentifier! + ".1.month.subscription"
        static let oneMonthNoTrail = Bundle.main.bundleIdentifier! + ".1.month.no.trail.subscription"
        static let twoMonths = Bundle.main.bundleIdentifier! + ".2.months.subscription"
        static let oneYear = Bundle.main.bundleIdentifier! + ".1.year.subscription"
        static let lifetime = Bundle.main.bundleIdentifier! + ".lifetime"
    }
    
    private let bag = DisposeBag()
    private let paymentQueueObserverSubject: PublishSubject<Void> = PublishSubject()
    
    private let productsSubject: Variable<[Product]> = Variable([])
    var productsObservable: Observable<[Product]> {
        return productsSubject.asObservable()
    }
    
    private let hasValidReceiptSubject: Variable<Bool> = Variable(false)
    var hasValidReceiptObservable: Observable<Bool> {
        return hasValidReceiptSubject.asObservable()
    }
    
    var hasValidReceipt: Bool {
        return hasValidReceiptSubject.value
    }
    
    private let overrideSettingSubject: PublishSubject<Void> = PublishSubject()
    
    override init() {
        super.init()
        
        let now = Observable.just(())
        let background = NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationDidEnterBackground, object: nil).mapToVoid()
        let active = NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationDidBecomeActive, object: nil).mapToVoid()
        
        Observable.of(now, background, active, paymentQueueObserverSubject.asObservable(), overrideSettingSubject.asObservable()).merge()
            .throttle(1, scheduler: MainScheduler.instance)
            .map(StoreService.isReceiptValid)
            .bind(to: hasValidReceiptSubject)
            .disposed(by: bag)
        
        SKPaymentQueue.default().add(self)
    }
    
    func loadProducts() {

        let productIds = Set([ProductIndentifiers.oneMonth, ProductIndentifiers.oneMonthNoTrail, ProductIndentifiers.oneYear, ProductIndentifiers.lifetime])
        let productRequest = SKProductsRequest(productIdentifiers: productIds)
        _ = productRequest.rx.productsRequest
        .do(onError: { (error) in
            logger.error(error)
        })
        .map { (response) -> [Product] in
            return response.products.map { Product(with: $0) }
        }.bind(to: productsSubject)
        
        productRequest.start()
    }
    
    func purchaseMonthly() -> Observable<Purchase> {
        let montlyProduct = productsSubject.value.filter { $0.isMonthBasedPeriod && $0.hasTrail }.first
        guard let product = montlyProduct else {
            return Observable.empty()
        }
        return purchase(product: product).map({ (success) -> Purchase in
            return Purchase(product: product, success: success)
        })
    }
    
    func purchaseMonthlyNoTrail() -> Observable<Purchase> {
        let montlyProduct = productsSubject.value.filter { $0.isMonthBasedPeriod && !$0.hasTrail }.first
        guard let product = montlyProduct else {
            return Observable.empty()
        }
        return purchase(product: product).map({ (success) -> Purchase in
            return Purchase(product: product, success: success)
        })
    }
    
    func purchaseLifetime() -> Observable<Purchase> {
        let lifetimeProduct = productsSubject.value.filter { $0.product.productIdentifier == ProductIndentifiers.lifetime }.first
        guard let product = lifetimeProduct else {
            return Observable.empty()
        }
        return purchase(product: product).map({ (success) -> Purchase in
            return Purchase(product: product, success: success)
        })
    }
    
    func purchaseYearly() -> Observable<Purchase> {
        let yearlyProduct = productsSubject.value.filter { !$0.isMonthBasedPeriod }.first
        guard let product = yearlyProduct else {
            return Observable.empty()
        }
        return purchase(product: product).map({ (success) -> Purchase in
            return Purchase(product: product, success: success)
        })
    }
    
    func restorePurchase() -> Observable<Void> {
        return SKPaymentQueue.default().rx.restoreCompletedTransactions()
        .do(onNext: { (_) in
            logger.debug("Restored all transactions")
        }, onError: { (error) in
            logger.error(error)
        })
        .map { _ in
            
            guard Bundle.main.appStoreReceiptURL != nil else {
                throw StoreServiceError.neverHadASubscription
            }
            
            guard StoreService.isReceiptValid() else {
                if let date = StoreService.expirationDate() {
                    throw R.string.localizable.receiptExpired(date.asString())
                }
                throw StoreServiceError.receiptExpired
            }
        }
    }
    
    func overrideValiditidy(to isValid: Bool) {
        Static.shouldOverrideSettings = isValid
        overrideSettingSubject.onNext(())
    }
    
    func removeAsObserverFromPaymentQueue() {
        SKPaymentQueue.default().remove(self)
    }
    
    private func purchase(product: Product) -> Observable<Bool> {
        return SKPaymentQueue.default().rx.add(product: product.product, verifyWith: Static.itcSecret)
            .do(onNext: { (transaction) in
                logger.debug("Created transcaction: \(transaction) state \(transaction.transactionState.rawValue)")
            }, onError: { (error) in
                logger.error(error)
            })
            .filter({ (transaction) -> Bool in
                transaction.transactionState != .purchasing
            })
            .map({ (transaction) -> Bool in
                transaction.transactionState == .purchased
            }).flatMap({ [unowned self] (success) -> Observable<Bool> in
                #if DEBUG
                    logger.debug("checking if we need to refresh the receipt since we are on debug")
                    if !success || (success && Bundle.main.appStoreReceiptURL != nil) {
                        logger.debug("no refreshing needed, we found the receipt on the device")
                        return Observable.just(success)
                    }
                    logger.debug("start refreshing receipt")
                    return self.refreshReceipt().map({ (_) -> Bool in
                        logger.debug("receipt refresh finished")
                        return success
                    })
                #else
                logger.debug("no refrehsing needed, just return success \(success)")
                return Observable.just(success)
                #endif
            })
    }
    
    private func refreshReceipt() -> Observable<Void> {
        let request = SKReceiptRefreshRequest()
        let obs = request.rx.refresh.mapToVoid()
        request.start()
        return obs
    }
    
    private class func isReceiptValid() -> Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            #if DEBUG
                if Static.shouldOverrideSettings {
                    return true
                }
            #endif
        guard let url = Bundle.main.appStoreReceiptURL,
            let bundleIdentifier = Bundle.main.bundleIdentifier,
            let dtReceipt = Receipt(contentsOfURL: url),
            let rBundleIndentifier = dtReceipt.bundleIdentifier,
            let rExpirationDate = dtReceipt.sortedInAppPurchaseReceipts.last?.subscriptionExpirationDate,
            bundleIdentifier == rBundleIndentifier, check(expirationDate: rExpirationDate) else {
                StoreService.log()
                return false
        }
        
        return true
        #endif
    }
    
    private class func check(expirationDate: Date) -> Bool {
        #if DEBUG
        return moment(expirationDate).add(1, .Minutes).date.timeIntervalSince1970 > Date().timeIntervalSince1970
        #else
        return moment(expirationDate).add(2, .Days).date.timeIntervalSince1970 > Date().timeIntervalSince1970
        #endif
    }
    
    private class func log() {
        logger.debug("Receipt validation")
        if Bundle.main.appStoreReceiptURL == nil {
            logger.debug("No AppStore URL")
            return
        }
        if Bundle.main.bundleIdentifier == nil {
            logger.debug("No bundle identifier URL")
            return
        }
        if Receipt(contentsOfURL: Bundle.main.appStoreReceiptURL!) == nil {
            logger.debug("No receipt")
            return
        }
        let receipt = Receipt(contentsOfURL: Bundle.main.appStoreReceiptURL!)
        if receipt == nil {
            logger.debug("No receipt")
            return
        }
        if receipt!.bundleIdentifier == nil {
            logger.debug("No receipt bundle identifier")
            return
        }
        
        receipt!.inAppPurchaseReceipts?.forEach({ (receipt) in
            if let date = receipt.purchaseDate {
                logger.debug("Purchase Date \(date.asString())")
            }
            if let date = receipt.subscriptionExpirationDate {
                logger.debug("Expiration Date \(date.asString())")
            }
        })
        
        let expirationDate = receipt!.inAppPurchaseReceipts?.last?.subscriptionExpirationDate
        if expirationDate == nil {
            logger.debug("No expiration date")
            return
        }
        if Bundle.main.bundleIdentifier != receipt!.bundleIdentifier {
            logger.debug("Bundles not equal: \(Bundle.main.bundleIdentifier!) vs \(receipt!.bundleIdentifier!)")
            return
        }
        let now = Date().timeIntervalSince1970
        if expirationDate!.timeIntervalSince1970 <  now {
            
            if moment(expirationDate!).add(2, .Days).date.timeIntervalSince1970 < now {
                Analytics.subscriptionIsOutsideGracePeriod.logEvent()
                logger.debug("Already expired \(expirationDate!.asString())")
            } else {
                logger.debug("Already expired but within grace period \(expirationDate!.asString())")
            }
            
            return
        }
    }
    
    class func expirationDate() -> Date? {
        guard let url = Bundle.main.appStoreReceiptURL, let dtReceipt = Receipt(contentsOfURL: url) else {
                return nil
        }
        return dtReceipt.inAppPurchaseReceipts?.last?.subscriptionExpirationDate
    }
}

// MARK: - SKPaymentTransactionObserver

extension StoreService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        }
        
        paymentQueueObserverSubject.onNext(())
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        logger.debug("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        logger.debug("User purchased product id: \(transaction.payment.productIdentifier)")
        
        queue.finishTransaction(transaction)
        //This should basically upload the data to the server and unlock the pro features
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        logger.debug("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        //This should basically upload the data to the server and unlock the pro features
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        let errorMessage = transaction.error?.localizedDescription ?? "no error description"
        logger.error("Purchase failed for product id: \(transaction.payment.productIdentifier) with error '\(errorMessage)'")
        queue.finishTransaction(transaction)
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        logger.error("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        Analytics.upsellPurchaseViaAppStoreDirectly.logEvent(["productIdentifier": product.productIdentifier.asNSString])
        return true
    }
}

extension Receipt {
    
    /// Returns the in app purchases sorted by expiration date, the one with the latest
    /// expiration date is returned last, we had to do that since the  `inAppPurchaseReceipts`
    /// per default doesn't return a sorted fucking array!
    var sortedInAppPurchaseReceipts: [Kvitto.InAppPurchaseReceipt] {
        let list = inAppPurchaseReceipts ?? []
        return list.sorted(by: { (first, second) -> Bool in
            let date1 = first.subscriptionExpirationDate ?? Date()
            let date2 = second.subscriptionExpirationDate ?? Date()
            return date1.timeIntervalSince1970 < date2.timeIntervalSince1970
        })
    }
}
