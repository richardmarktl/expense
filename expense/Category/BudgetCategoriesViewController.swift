//
// Created by Richard Marktl on 2019-04-24.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI
import RxSwift
import InvoiceBotSDK
import CoreDataExtensio

class BudgetCategoriesViewController: CollectionModelController<BudgetCategoriesModel>, EmptyViewable {
    // the EmptyViewable properties
    var emptyTitle: String = ""
    var emptyMessage: String = ""
    var emptyViewInsertBelowView: UIView?

//    @IBOutlet weak var addButton: HoverButton!
//    @IBOutlet weak var addContactButton: HoverButton!
    public var entry: BudgetEntry?
    public var wallet: BudgetWallet?

    fileprivate let searchSubject: PublishSubject<String> = PublishSubject()
    var searchObservable: Observable<String> {
        return searchSubject.asObservable().startWith("")
    }

    open override func createModel() -> BudgetCategoriesModel {
        return BudgetCategoriesModel(searchObservable: searchObservable, with: CoreDataContainer.instance!.mainContext)
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

        collectionView.register(R.nib.budgetCategoryCell)
        collectionView.register(R.nib.createWalletCell)

        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.category.logEvent()
    }
}