//
//  WalletViewController.swift
//  expense
//
//  Created by Richard Marktl on 04.04.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData
import CoreDataExtensio
import CommonUI
import SettingsUI

class WalletViewController: CollectionModelController<WalletsModel> {
    private let emptyViewAddSubject: PublishSubject<Void> = PublishSubject()

//    @IBOutlet weak var addButton: HoverButton!
//    @IBOutlet weak var addContactButton: HoverButton!
    @IBAction public func showSettings() {
        let podBundle = Bundle(for: SettingsController.self)
        let storyboard = UIStoryboard(name: "Settings", bundle: podBundle)
        let vc = storyboard.instantiateInitialViewController()!
        self.present(vc, animated: true)
    }

    fileprivate let searchSubject: PublishSubject<String> = PublishSubject()
    var searchObservable: Observable<String> {
        return searchSubject.asObservable().startWith("")
    }

    override open func createModel() -> WalletsModel {
        context = CoreDataContainer.instance!.mainContext
        return WalletsModel(searchObservable: searchObservable, with: context)

    }

    override func viewDidLoad() {
//        emptyTitle = R.string.localizable.noWallets()
//        emptyMessage = R.string.localizable.noClientMessage()
//        emptyViewInsertBelowView = addContactButton
//
//        addContactButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
//            if !CurrentAccountState.isProExpired {
//                self.addContact()
//            } else {
//                UpsellTrialExpiredController.present(in: self)
//            }
//        }).disposed(by: bag)
//
//        addButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
//            if !CurrentAccountState.isProExpired {
//                let nCtr = ClientViewController.createItem()
//                Analytics.clientNew.logEvent()
//                self.present(nCtr, animated: true)
//            } else {
//                UpsellTrialExpiredController.present(in: self)
//            }
//        }).disposed(by: bag)



        super.viewDidLoad()

        collectionView.register(R.nib.createWalletCell)
        collectionView.register(R.nib.walletCell)

        navigationController?.navigationBar.prefersLargeTitles = true

        title = R.string.localizable.wallets()
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.wallet.logEvent()
    }
}
