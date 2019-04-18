//
// Created by Richard Marktl on 2019-04-18.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CommonUI
import RxSwift
import CoreDataExtensio

class BudgetEntriesViewController: CollectionModelController<BudgetEntriesModel> {
    private let emptyViewAddSubject: PublishSubject<Void> = PublishSubject()

//    @IBOutlet weak var addButton: HoverButton!
//    @IBOutlet weak var addContactButton: HoverButton!

    fileprivate let searchSubject: PublishSubject<String> = PublishSubject()
    var searchObservable: Observable<String> {
        return searchSubject.asObservable().startWith("")
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

        context = CoreDataContainer.instance!.mainContext
        model = BudgetEntriesModel(searchObservable: searchObservable, with: context)

        super.viewDidLoad()

//        collectionView.register(R.nib.createWalletCell)
//        collectionView.register(R.nib.walletCell)

        navigationController?.navigationBar.prefersLargeTitles = true

        title = R.string.localizable.wallets()
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.wallet.logEvent()
    }
}
