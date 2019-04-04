//
//  UpsellAllPlansController.swift
//  InVoice
//
//  Created by Georg Kitz on 02.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class UpsellAllPlansController: UpsellBaseController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var saveLabel: UIButton!
    @IBOutlet weak var yearlyBuyButton: BuyButtonContainer!
    @IBOutlet weak var yearlyBuyButtonSubTitle: UIButton!
    
    @IBOutlet weak var uniqueOfferLabel: UIButton!
    @IBOutlet weak var trialButton: BuyButtonContainer!
    @IBOutlet weak var trialButtonSubTitle: UIButton!
    
    @IBOutlet weak var lifetimeOfferLabel: UIButton!
    @IBOutlet weak var lifetimeBuyButton: BuyButtonContainer!
    @IBOutlet weak var lifetimeBuyButtonSubTitle: UIButton!
    
    @IBOutlet weak var whyGoPro: UILabel!
    
    class func present(in ctr: UIViewController) {
        guard let this = R.storyboard.upsell.upsellAllPlansController() else {
            return
        }
        this.modalPresentationStyle = .formSheet
        ctr.present(this, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocalization()
        registerYearlyEvent(observable: yearlyBuyButton.tapObservable)
        registerMonthlyTrialEvent(observable: trialButton.tapObservable)
    }
    
    override func handleProductsLoaded(_ products: [Product]) {
        super.handleProductsLoaded(products)
        
        let yearlyProduct = products.filter { $0.isMonthBasedPeriod == false }.first
        if let yearlyProduct = yearlyProduct {
            yearlyBuyButton.rightText = yearlyProduct.periodPrice
            
            let title = R.string.localizable.upsellYearlyBilledAt(yearlyProduct.monthlyPrice)
            yearlyBuyButtonSubTitle.setTitle(title, for: .normal)
        }
        
        let monthlyProductNoTrail = products.filter { $0.isMonthBasedPeriod && !$0.hasTrail }.first
        if let monthlyProduct = monthlyProductNoTrail {
            trialButton.rightText = R.string.localizable.upsellTryFree()
            
            let title = R.string.localizable.upsellMonthlyBilledAt(monthlyProduct.periodPrice)
            trialButtonSubTitle.setTitle(title, for: .normal)
        }
        
        let lifetimeProduct = products.filter { $0.product.productIdentifier == StoreService.ProductIndentifiers.lifetime }.first
        if let lifetimeProduct = lifetimeProduct {
            lifetimeBuyButton.rightText = lifetimeProduct.periodPrice
            lifetimeBuyButtonSubTitle.setTitle(R.string.localizable.oneTimePayment(), for: .normal)
        }
    }
    
    private func updateLocalization() {
        titleLabel.text = R.string.localizable.upsellChooseYourSubscription()
        
        saveLabel.setTitle(R.string.localizable.upsellSavePercentage(), for: .normal)
        yearlyBuyButton.leftText = R.string.localizable.upsell1Year()
        
        uniqueOfferLabel.setTitle(R.string.localizable.upsellUniqueOffer(), for: .normal)
        trialButton.leftText = R.string.localizable.upsell7DayTrial()
        
        lifetimeOfferLabel.setTitle(R.string.localizable.payOnce(), for: .normal)
        lifetimeBuyButton.leftText = R.string.localizable.lifetime()
        
        whyGoPro.text = R.string.localizable.upsellWhyGoPro()
    }
}
