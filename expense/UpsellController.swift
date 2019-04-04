//
//  UpsellController.swift
//  InVoice
//
//  Created by Georg Kitz on 22/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Horreum
import StoreKit

class UpsellController: UpsellFirstBaseController {

    @IBOutlet weak var startTrail: TrailButtonContainer!
    @IBOutlet weak var trailStackView: UIStackView!
    @IBOutlet weak var monthlySubscriptionButton: ActionButton!
    @IBOutlet weak var defaultSubscriptionButton: ActionButton!
    
    class func present(in ctr: UIViewController) {
        guard let this = R.storyboard.upsell.upsellController() else {
            return
        }
        ctr.present(this, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trailStackView.isHidden = true
        monthlySubscriptionButton.isHidden = false
        
        registerYearlyEvent(observable: defaultSubscriptionButton.tapObservable)
        
        startTrail.topText = R.string.localizable.startTrailWeek()
        registerMonthlyTrialEvent(observable: startTrail.tapObservable)
    }
    
    override func handleProductsLoaded(_ products: [Product]) {
        super.handleProductsLoaded(products)
        
        let yearlyProduct = products.filter { $0.isMonthBasedPeriod == false }.first
        if let yearlyProduct = yearlyProduct {
            defaultSubscriptionButton.title = R.string.localizable.monthsSubscription() + " " + yearlyProduct.periodPrice
        }
        
        let monthlyProduct = products.filter { $0.isMonthBasedPeriod && $0.hasTrail }.first
        if let monthlyProduct = monthlyProduct {
            startTrail.bottomText = R.string.localizable.thenPerMonth(monthlyProduct.monthlyPrice)
        }
        
        let monthlyProductNoTrail = products.filter { $0.isMonthBasedPeriod && !$0.hasTrail }.first
        if let monthlyProduct = monthlyProductNoTrail {
            monthlySubscriptionButton.title = R.string.localizable.monthSubscription() + " " + monthlyProduct.monthlyPrice
        }
    }
}
