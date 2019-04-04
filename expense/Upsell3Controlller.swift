//
//  Upsell3Controlller.swift
//  InVoice
//
//  Created by Georg Kitz on 26.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import StoreKit
import Crashlytics
import SwiftRichString

enum Upsell3Mode {
    case showMonthlyAndYearly
    case showYearlyOnly
    case showYearlyOnlyAndSubscriptionButton
}

class Upsell3Controller: UpsellBaseController {
    
    private var mode: Upsell3Mode = .showMonthlyAndYearly
    private var statusBarStyle: UIStatusBarStyle = .lightContent
    
    @IBOutlet weak var yearlySubscriptionButton: BigSaleButton!
    @IBOutlet weak var monthlySubscriptionButton: BigSaleButton!

    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var limitedOffer: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var yearlyTotalLabel: UILabel!
    @IBOutlet weak var cloudsImageView: UIImageView!
    @IBOutlet weak var topInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerInset: NSLayoutConstraint!
    @IBOutlet weak var monthlyContainerView: UIStackView!
    @IBOutlet weak var subscriptionButton: ActionButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    class func present(in ctr: UIViewController, mode: Upsell3Mode) {
        guard let this = R.storyboard.upsell.upsell3Controller() else {
            return
        }
        this.modalPresentationStyle = .formSheet
        this.mode = mode
        ctr.present(this, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleControllerMode()
        handleShowSubscriptionIniTunes()
        updateCloudsImageViewIfNeeded()
        changeStatusBarIfNeeded()
        subscriptionButtonAction()
        updateLocalizableStrings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.adjustedContentInsetDidChange()
        scrollView.scrollIndicatorInsets = view.safeAreaInsets
    }
    
    fileprivate func handleShowSubscriptionIniTunes() {
        subscriptionButton.tapObservable.subscribe(onNext: {
            Analytics.accountManageSubscriptions.logEvent()
            
            guard let url = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions") else { return }
            UIApplication.shared.open(url, options: [:])
            
        }).disposed(by: bag)
    }
    
    fileprivate func handleControllerMode() {
        switch mode {
        case .showMonthlyAndYearly:
            subscriptionButton.isHidden = true
            monthlyContainerView.isHidden = false
        case .showYearlyOnly:
            subscriptionButton.isHidden = true
            monthlyContainerView.isHidden = true
        case .showYearlyOnlyAndSubscriptionButton:
            subscriptionButton.isHidden = false
            monthlyContainerView.isHidden = true
        }
    }
    
    fileprivate func updateCloudsImageViewIfNeeded() {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cloudsImageView.image = R.image.clouds_ipad()
            topInsetConstraint.constant = 0
            buttonContainerInset.constant = 10
        }
    }
    
    fileprivate func changeStatusBarIfNeeded() {
        scrollView.rx.contentOffset.subscribe(onNext:{ [unowned self] point in
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                if point.y >= 195 && self.statusBarStyle == .lightContent {
                    self.statusBarStyle = .default
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.closeButton.isHidden = true
                } else if point.y < 195 && self.statusBarStyle == .default {
                    self.statusBarStyle = .lightContent
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.closeButton.isHidden = false
                }
            }
        }).disposed(by: bag)
    }
    
    fileprivate func subscriptionButtonAction() {
        registerYearlyEvent(observable: yearlySubscriptionButton.tapObservable)
        registerMonthlyTrialEvent(observable: monthlySubscriptionButton.tapObservable)
    }
    
    override func handleProductsLoaded(_ products: [Product]) {
        super.handleProductsLoaded(products)
        
        let yearlyProduct = products.filter { $0.isMonthBasedPeriod == false }.first
        if let yearlyProduct = yearlyProduct {
            yearlySubscriptionButton.topText = yearlyProduct.monthlyPrice
            yearlyTotalLabel.text = R.string.localizable.upsellBilledYearlyAt(yearlyProduct.periodPrice)
        }
        
        let monthlyProductNoTrail = products.filter { $0.isMonthBasedPeriod && !$0.hasTrail }.first
        if let monthlyProduct = monthlyProductNoTrail {
            monthlySubscriptionButton.topText = monthlyProduct.periodPrice
        }
    }
    
    private func updateLocalizableStrings() {
        subscriptionButton.title = R.string.localizable.manageYourSubscription.key
        
        saveLabel.text = R.string.localizable.upsellSavePercentage()
        limitedOffer.text = R.string.localizable.upsellLimitedOffer()
        orLabel.text = R.string.localizable.upsellOr()
        
        let style = StyleGroup.regularMediumMix(fontSize: 18, textColor: UIColor.white)
        yearlySubscriptionButton.bottomAttributedText = R.string.localizable.upsellPerMonthBilledYearly().set(style: style)
        monthlySubscriptionButton.bottomAttributedText = R.string.localizable.upsellPerMonthBilledMonthly().set(style: style)
    }
}
