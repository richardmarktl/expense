//
//  TrialExpiredController.swift
//  InVoice
//
//  Created by Georg Kitz on 25.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UpsellTrialExpiredController: UIViewController {
    
    private let bag = DisposeBag()
    
    @IBOutlet weak var trialEndedLabel: UILabel!
    @IBOutlet weak var thankYouLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var plansButton: ActionButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cloudsImageView: UIImageView!
    
    class func present(in ctr: UIViewController) {
        guard let this = R.storyboard.upsell.upsellTrialExpiredController() else {
            return
        }
        let nCtr = NavigationController.init(rootViewController: this)
        nCtr.modalPresentationStyle = .formSheet
        nCtr.setNavigationBarHidden(true, animated: false)
        ctr.present(nCtr, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cloudsImageView.image = R.image.clouds_ipad()
        }
        
        Analytics.upsellTrialExpiredCtrShown.logEvent()
        
        trialEndedLabel.text = R.string.localizable.upsellTrialEnded()
        thankYouLabel.text = R.string.localizable.upsellThankYou()
        informationLabel.text = R.string.localizable.upsellInformation()
        plansButton.title = R.string.localizable.upsellShowPlans.key
        continueButton.setTitle(R.string.localizable.upsellContinueInReadOnlyMode(), for: .normal)
        
        plansButton.tapObservable.subscribe(onNext: { [weak self] (_) in
            Analytics.upsellTrialExpiredPlans.logEvent()
            guard let ctr = R.storyboard.upsell.upsell3Controller() else {return}
            self?.navigationController?.pushViewController(ctr, animated: true)
        }).disposed(by: bag)
        
        continueButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            Analytics.upsellTrialExpiredContinue.logEvent()
            self?.dismiss(animated: true)
        }).disposed(by: bag)
    }
}
