//
//  ItemsViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 16/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import Horreum

class ItemsViewController: SearchableTableModelController<ItemItem, ItemsModel> {
    
    @IBOutlet weak var addButton: HoverButton!
    private let emptyViewAddSubject: PublishSubject<Void> = PublishSubject()
    
    override func viewDidLoad() {
        
        emptyTitle = R.string.localizable.noItemTitle()
        emptyMessage = R.string.localizable.noItemMessage()
        emptyViewInsertBelowView = addButton
        
        context = Horreum.instance!.mainContext
        model = ItemsModel(searchObservable: searchObservable, with: context)
        
        super.viewDidLoad()
        
        tableView.register(R.nib.itemCell)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        addButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            
                if !CurrentAccountState.isProExpired {
                    let nCtr = ItemViewController.createItem()
                    Analytics.itemNew.logEvent()
                    self.present(nCtr, animated: true)
                } else {
                    UpsellTrialExpiredController.present(in: self)
                }
                
            }).disposed(by: bag)
        
        title = R.string.localizable.items()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.item.logEvent()
    }
}
