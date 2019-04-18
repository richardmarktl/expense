//
//  SettingsController.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import StoreKit
import CoreDataExtensio
import CommonUI

// class SettingsController: TableModelController<SettingsModel>, ShowAccountLoginable {
class SettingsController: TableModelController<SettingsModel> {
    @IBOutlet weak var igButton: UIButton!
    @IBOutlet weak var twButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    @IBOutlet weak var restoreActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var upsellHeader: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        context = CoreDataContainer.instance?.mainContext

//        #if DEBUG
//        tableView.register(R.nib.switchCell)
//        tableView.register(R.nib.subtitleCell)
//        if let debugSection = model.sections.last as? DebugSection {
//            debugSection.isProAccount.data.asObservable().subscribe(onNext: { [unowned self](value) in
//                if value {
//                    self.showAccountControllerIfNeeded()
//                }
//            }).disposed(by: bag)
//        }
//        #endif

        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        setupSocialMedia()

        versionLabel.text = AppInfo.name + " (\(AppInfo.version).\(AppInfo.build))"
//        upSellBanner.rx.controlEvent(.touchUpInside).subscribe(onNext: { [unowned self] (_) in
//            Analytics.settingsBanner.logEvent()
//            Upsell2Controller.present(in: self, trackDimsiss: true)
//        }).disposed(by: bag)

        StoreService.instance.hasValidReceiptObservable.distinctUntilChanged().subscribe(onNext: { [unowned self] (value) in
            self.tableView.tableHeaderView = value ? nil : self.upsellHeader
        }).disposed(by: bag)

//        restorePurchaseButton.rx.tap.asObservable().flatMap { [unowned self](_) -> Observable<Void> in
//            // Analytics.settingsRestore.logEvent()
//            self.restorePurchaseButton.isHidden = true
//            self.restoreActivityIndicator.isHidden = false
//
//            return self.model.restorePurchase()
//            .do(onNext: { [weak self] in
//                // self?.showAccountControllerIfNeeded()
//                print("showAccountControllerIfNeeded")
//            }, onError: { (error) in
//                logger.error(error)
//                ErrorPresentable.show(error: error)
//            }).catchErrorJustReturn(()).observeOn(MainScheduler.instance)
//
//        }.subscribe(onNext: { [weak self](_) in
//
//            self?.restorePurchaseButton.isHidden = false
//            self?.restoreActivityIndicator.isHidden = true
//
//        }).disposed(by: bag)
    }

    @IBAction func done() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Analytics.settings.logEvent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let header = tableView.tableHeaderView else {
            return
        }

        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if header.frame.height != size.height {
            header.frame.size.height = size.height
            tableView.tableHeaderView = header
            tableView.layoutIfNeeded()
        }
    }

    private func setupSocialMedia() {
        fbButton.rx.tap.subscribe(onNext: {
            // Analytics.settingsFB.logEvent()
            UIApplication.shared.open(URL(string: "https://www.facebook.com/invoicebot")!, options: [:])
        }).disposed(by: bag)

        twButton.rx.tap.subscribe(onNext: {
            // Analytics.settingsTW.logEvent()
            UIApplication.shared.open(URL(string: "https://twitter.com/invoicebotapp")!, options: [:])
        }).disposed(by: bag)

        igButton.rx.tap.subscribe(onNext: {
            // Analytics.settingsIG.logEvent()
            UIApplication.shared.open(URL(string: "https://www.instagram.com/invoicebot")!, options: [:])
        }).disposed(by: bag)
    }
}
