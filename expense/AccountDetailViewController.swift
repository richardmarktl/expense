//
//  AccountDetailViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 23/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import SwiftRichString
import RxSwift

class AccountDetailViewController: TableModelController<AccountDetailModel> {
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var validLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        greetingLabel.text = model.name
        title = R.string.localizable.invoiceBotAccount()
        
        updateUserInterface()
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let currentStateOfSubscription = StoreService.instance.hasValidReceipt
        StoreService.instance.hasValidReceiptObservable.filterTrue().filter { (_) -> Bool in
            return currentStateOfSubscription == true
        }.subscribe(onNext: { [unowned self] (_) in
            self.model = AccountDetailModel(with: self.context)
            self.tableView.reloadData()
            
            self.updateUserInterface()
        }).disposed(by: bag)
    }
    
    private func updateUserInterface() {
        validLabel.attributedText = model.validUntil.set(style: StyleGroup.expireStyleGroup())
        
        let header = tableView.tableHeaderView!
        tableView.setAndLayoutTableHeaderView(header: header)
    }
}
