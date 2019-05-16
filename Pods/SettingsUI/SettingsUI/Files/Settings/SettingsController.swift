//
//  SettingsController.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import RxSwift
import StoreKit
import CoreDataExtensio
import CommonUtil
import CommonUI

open class SettingsController: TableModelController<SettingsModel> {
    @IBOutlet weak var igButton: UIButton!
    @IBOutlet weak var twButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    @IBOutlet weak var restoreActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var upsellHeader: UIView!

    public var storeService: StoreService?

    open override func viewDidLoad() {
        super.viewDidLoad()
        context = CoreDataContainer.instance?.mainContext

        let bundle = Bundle.podBundle
        let userCell = "SettingsUserCell"
        let settingsCell = "SettingsCell"
        tableView.register(UINib(nibName: userCell, bundle: bundle), forCellReuseIdentifier: userCell)
        tableView.register(UINib(nibName: settingsCell, bundle: bundle), forCellReuseIdentifier: settingsCell)

        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        setupSocialMedia()

        versionLabel.text = AppInfo.name + " (\(AppInfo.version).\(AppInfo.build))"

        storeService?.hasValidReceiptObservable.distinctUntilChanged().subscribe(onNext: { [unowned self] (value) in
            self.tableView.tableHeaderView = value ? nil : self.upsellHeader
        }).disposed(by: bag)

        restorePurchaseButton.rx.tap.asObservable().flatMap { [unowned self](_) -> Observable<Void> in
            // Analytics.settingsRestore.logEvent()
            self.restorePurchaseButton.isHidden = true
            self.restoreActivityIndicator.isHidden = false

            var observable = Observable.just(())
            if let service = self.storeService {
                observable = service.restorePurchase()
            }

            return observable.do(onNext: { [unowned self] in
                self.showRestoreView()
            }, onError: { (error) in
                ErrorPresentable.show(error: error)
            }).catchErrorJustReturn(()).observeOn(MainScheduler.instance)

        }.subscribe(onNext: { [unowned self](_) in
            self.restorePurchaseButton.isHidden = false
            self.restoreActivityIndicator.isHidden = true
        }).disposed(by: bag)
    }

    open func showRestoreView() {
        print("showAccountControllerIfNeeded")
        fatalError("Please implement me")
    }

    @IBAction func done() {
        self.dismiss(animated: true, completion: nil)
    }

    open override func viewDidLayoutSubviews() {
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
            UIApplication.shared.open(URL(string: AppInfo.facebookURL)!, options: [:])
        }).disposed(by: bag)

        twButton.rx.tap.subscribe(onNext: {
            // Analytics.settingsTW.logEvent()
            UIApplication.shared.open(URL(string: AppInfo.twitterURL)!, options: [:])
        }).disposed(by: bag)

        igButton.rx.tap.subscribe(onNext: {
            // Analytics.settingsIG.logEvent()
            UIApplication.shared.open(URL(string: AppInfo.instagramURL)!, options: [:])
        }).disposed(by: bag)
    }
}
