//
//  Upsell2Controller.swift
//  InVoice
//
//  Created by Georg Kitz on 12.04.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Horreum
import StoreKit

class Upsell2Controller: UpsellFirstBaseController {
    
    private var trackDismissal: Bool = false
    
    @IBOutlet weak var startTrail: ActionButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var showAllPlansButton: UIButton!
    
    class func present(in ctr: UIViewController, trackDimsiss: Bool = false) {
        guard let this = R.storyboard.upsell.upsell2Controller() else {
            return
        }
        
        this.trackDismissal = trackDimsiss
        
        let nCtr = NavigationController.init(rootViewController: this)
        nCtr.modalPresentationStyle = .formSheet
        nCtr.setNavigationBarHidden(true, animated: false)
        
        ctr.present(nCtr, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        offerToContinueWithoutPROFeatures = true
        closeButton.setTitle(R.string.localizable.upsell2Continue(), for: .normal)
        
        startTrail.title = R.string.localizable.upsellContinue()
        registerMonthlyTrialEvent(observable: startTrail.tapObservable)
        
        showAllPlansButton.setTitle(R.string.localizable.upsellShowPlans() + " ›", for: .normal)
        showAllPlansButton.rx.tap.subscribe(onNext: { [unowned self] in
            UpsellAllPlansController.present(in: self)
        }).disposed(by: bag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // basically if the view appears and we suddenly have a valid receipt, the user bought
        // the subscription from the all plans screen, thus we dismiss this controller too
        if StoreService.instance.hasValidReceipt {
            dismiss(animated: true)
        }
    }
    
    override func handleProductsLoaded(_ products: [Product]) {
        super.handleProductsLoaded(products)
        
        let monthlyProduct = products.filter { $0.isMonthBasedPeriod && $0.hasTrail }.first
        if let monthlyProduct = monthlyProduct {
            titleLabel.text = R.string.localizable.upsell2Header()
            subtitleLabel.text = R.string.localizable.thenPerMonth(monthlyProduct.monthlyPrice)
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        if trackDismissal && !StoreService.instance.hasValidReceipt {
            UserDefaults.increaseUpsellCancelCounter()
        }
    }
}
