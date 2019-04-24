//
// Created by Richard Marktl on 2019-04-18.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CommonUI
import RxSwift
import CoreDataExtensio
import InvoiceBotSDK

class BudgetEntriesViewController: CollectionModelController<BudgetEntriesModel>, EmptyViewable {
    // the EmptyViewable properties
    var emptyTitle: String = ""
    var emptyMessage: String = ""
    var emptyViewInsertBelowView: UIView?

//    @IBOutlet weak var addButton: HoverButton!
//    @IBOutlet weak var addContactButton: HoverButton!
    public var wallet: BudgetWallet?

    fileprivate let searchSubject: PublishSubject<String> = PublishSubject()
    var searchObservable: Observable<String> {
        return searchSubject.asObservable().startWith("")
    }

    open override func createModel() -> BudgetEntriesModel {
        return BudgetEntriesModel(
                searchObservable: searchObservable,
                wallet: wallet,
                with: CoreDataContainer.instance!.mainContext
        )
    }

    @IBAction func done() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        emptyTitle = R.string.localizable.noEntries()
        emptyMessage = R.string.localizable.noEntriesMessage()
//        emptyViewInsertBelowView = addContactButton

        model.sectionsObservable.skip(1).subscribe(onNext: { [unowned self] (sections) in
            var show = true
            for section in sections where section.rows.count > 0 {
                show = false
                break
            }
            self.showEmptyViewController(show)
        }).disposed(by: bag)

        collectionView.register(R.nib.budgetEntryCell)
        collectionView.register(R.nib.createWalletCell)
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

//        collectionView.register(R.nib.createWalletCell)
//        collectionView.register(R.nib.walletCell)

        navigationController?.navigationBar.prefersLargeTitles = true
        if let wallet = wallet {
            title = wallet.name
        } else {
            title = R.string.localizable.wallets()
        }

        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.wallet.logEvent()
    }
}
