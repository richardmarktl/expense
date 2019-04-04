//
//  UpsellBaseController.swift
//  InVoice
//
//  Created by Georg Kitz on 12.04.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Crashlytics
import FirebaseCore
import StoreKit.SKError

class UpsellBaseController: UIViewController, ShowAccountLoginable {
    
    let bag = DisposeBag()
    var offerToContinueWithoutPROFeatures: Bool = false
    
    private var product: Product?
    private let dismissActionObservable: PublishSubject<Bool> = PublishSubject()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var activityIndicatorContainerView: UIView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var upsellInformationText: UILabel!
    @IBOutlet weak var subscriptionInformationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        track(event: .upsellShown)
        
        subscriptionInformationButton.setTitle(R.string.localizable.termsAPrivacy(), for: .normal)
        
        upsellInformationText.font = FiraSans.light.font(11)
        upsellInformationText.textColor = UIColor.blackish
        
        loadProducts()
        dismissAction()
        showSubscriptionInformation()
    }
    
    //    MARK: Public
    
    /// You register an event that triggers the trial pruchase
    ///
    /// - Parameter observable: the observable that should trigger the pruchase proccess
    func registerMonthlyTrialEvent(observable: Observable<Void>) {
        observable.flatMap({ [weak self](_) -> Observable<Bool> in
            self?.track(event: .upsellFreeTrail)
            return StoreService.instance.purchaseMonthly().do(onNext: { [weak self](purchase) in
                    self?.product = purchase.product
                }, onError: { [weak self](error) in
                    self?.logPurchaseFailed(error)
                })
                .map({ (purchase) -> Bool in
                    return purchase.success
                })
                .catchErrorJustReturn(false).observeOn(MainScheduler.instance)
        }).subscribe(onNext: { [weak self] (success) in
            self?.handle(purchaseSuccessful: success)
        }).disposed(by: bag)
        
        observable.subscribe(onNext: { [weak self] (_) in
            self?.showActivityIndicator(true)
        }).disposed(by: bag)
    }
    
    /// You register an event that triggers the yearly pruchase
    ///
    /// - Parameter observable: the observable that should trigger the pruchase proccess
    func registerYearlyEvent(observable: Observable<Void>) {
        observable.flatMap({ [weak self] (_) -> Observable<Bool> in
            self?.track(event: .upsellYearly)
            return StoreService.instance.purchaseYearly().do(onNext: { [weak self](purchase) in
                    self?.product = purchase.product
                }, onError: { [weak self](error) in
                    self?.logPurchaseFailed(error)
                })
            .map({ (purchase) -> Bool in
                return purchase.success
            })
            .catchErrorJustReturn(false).observeOn(MainScheduler.instance)
        }).subscribe(onNext: { [weak self] (success) in
            self?.handle(purchaseSuccessful: success)
        }).disposed(by: bag)
        
        observable.subscribe(onNext: { [weak self] (_) in
            self?.showActivityIndicator(true)
        }).disposed(by: bag)
    }
    
    /// You register an event that triggers the lifetime pruchase
    ///
    /// - Parameter observable: the observable that should trigger the pruchase proccess
    func registerLifetimeEvent(observable: Observable<Void>) {
        observable.flatMap({ [weak self] (_) -> Observable<Bool> in
            self?.track(event: .upsellLifetime)
            return StoreService.instance.purchaseLifetime().do(onNext: { [weak self](purchase) in
                self?.product = purchase.product
                }, onError: { [weak self](error) in
                    self?.logPurchaseFailed(error)
            })
                .map({ (purchase) -> Bool in
                    return purchase.success
                })
                .catchErrorJustReturn(false).observeOn(MainScheduler.instance)
        }).subscribe(onNext: { [weak self] (success) in
            self?.handle(purchaseSuccessful: success)
        }).disposed(by: bag)
        
        observable.subscribe(onNext: { [weak self] (_) in
            self?.showActivityIndicator(true)
        }).disposed(by: bag)
    }
    
    
    /// Once the products are loaded this method is called as callback
    /// intended to be overwritten by the subclasses
    ///
    /// - Parameter products: the loaded products
    func handleProductsLoaded(_ products: [Product]) {
        if products.count > 0 {
            showActivityIndicator(false)
        }
    }
    
    //    MARK: Private
    
    /// Successfull purchase callback
    ///
    /// - Parameter purchaseSuccessful: if the pruchase was successful
    private func handle(purchaseSuccessful: Bool) {
        logger.debug("purchase finished, success: \(purchaseSuccessful)")
        showActivityIndicator(false)
        
        if purchaseSuccessful {
            let alert = UIAlertController(title: R.string.localizable.information(), message: R.string.localizable.purchaseSuccessful(), preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: R.string.localizable.oK(), style: .cancel, handler: { [weak self] _ in
                self?.dismissActionObservable.onNext((true))
            })
            alert.addAction(okAction)
            
            logPurchase()
            present(alert, animated: true)
        }
    }
    
    
    /// Logs the reason why a pruchase failed, offers to continue without pro features if configured
    ///
    /// - Parameters:
    ///   - error: that happened
    private func logPurchaseFailed(_ error: Error) {
        logger.error(error)
        
        Crashlytics.sharedInstance().recordError(error)
        
        guard let error = error as? SKError else {
            return
        }
        
        let userInfo: [String: NSObject] = [
            "errorCode": NSNumber(value: error.errorCode),
            "error": error.localizedDescription as NSString
        ]
        if error.code == SKError.Code.paymentCancelled {
            track(event: .upsellCancelled, userInfo: userInfo)
            if offerToContinueWithoutPROFeatures {
                let alert = UIAlertController(title: R.string.localizable.information(), message: R.string.localizable.upsellContinueWithoutProFeatures(), preferredStyle: .alert)
                let continueAction = UIAlertAction(title: R.string.localizable.upsellContinue(), style: .default) { [weak self] (_) in
                    Analytics.upsellContinueWithoutProFeaturesAction.logEvent()
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true)
                    }
                }
                alert.addAction(continueAction)
                present(alert, animated: true) {
                    Analytics.upsellContinueWithoutProFeaturesShown.logEvent()
                }
            } else {
                ErrorPresentable.show(error: error)
            }
        } else {
            track(event: .upsellFailed, userInfo: userInfo)
            ErrorPresentable.show(error: error)
        }
    }
    
    /// Tracks events that happens during the pruchase process
    ///
    /// - Parameters:
    ///   - event: we want to track
    ///   - userInfo: additional information
    ///   - shouldSendImmidiatly: if we want to upload immidiatly
    private func track(event: Analytics, userInfo: [String: NSObject]? = nil, shouldSendImmidiatly: Bool = false) {
        let ctr = String(describing: type(of: self)) as NSString
        var data: [String: NSObject] = ["ctr": ctr]
        
        if let userInfo = userInfo {
            data.merge(userInfo) { $1 }
        }
        
        event.logEvent(data, shouldSendImmidiatly: shouldSendImmidiatly)
    }
    
    /// Track a purchase
    private func logPurchase() {
        guard let product = self.product else {
            return
        }
        Analytics.logPurchase(product)
        IAdTracking.track()
    }
    
    /// Loads all our offered products
    private func loadProducts() {
        StoreService.instance.loadProducts()
        StoreService.instance.productsObservable.takeWhile({ $0.count > 0 }).subscribe(onNext: { [weak self](products) in
            logger.debug("Loaded products: \(products)")
            self?.handleProductsLoaded(products)
        }).disposed(by: bag)
    }
    
    /// Action to hide the controller
    private func dismissAction() {
        let closeButtonObservable = closeButton.rx.tap.do(onNext: { [weak self] _ in
            self?.track(event: .upsellDismissed)
        }).map { _ in false }
        Observable.of(closeButtonObservable, dismissActionObservable).merge().take(1).subscribe(onNext: { [unowned self] (purchased) in
            self.dismiss(animated: true, completion: {
                if purchased {
                    self.showAccountControllerIfNeeded()
                }
            })
        }).disposed(by: bag)
    }
    
    /// Shows details about our subscription
    private func showSubscriptionInformation() {
        subscriptionInformationButton.rx.tap.subscribe(onNext: { [unowned self] in
            
            let pCtr = PrivacyController(nibName: nil, bundle: nil)
            let nCtr = UINavigationController(rootViewController: pCtr)
            pCtr.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
            _ = pCtr.navigationItem.rightBarButtonItem?.rx.tap.take(1).subscribe(onNext: { [weak pCtr](_) in
                pCtr?.dismiss(animated: true)
            })
            
            self.track(event: .upsellTT)
            self.present(nCtr, animated: true)
            
        }).disposed(by: bag)
    }
    
    /// Shows/Hides the pruchase buttons and activity indicator
    ///
    /// - Parameter show: wether we want to show the loading indicator
    private func showActivityIndicator(_ show: Bool) {
        buttonContainerView.isHidden = show
        activityIndicatorContainerView.isHidden = !show
    }
}
