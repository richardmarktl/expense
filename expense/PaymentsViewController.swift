//
//  PaymentViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 30/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import Horreum

class PaymentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPaidLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    private let bag = DisposeBag()
    private var model: PaymentsModel!
    
    var context: NSManagedObjectContext!
    var invoice: Invoice!
    
    var completionBlock: ((Client) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        model = PaymentsModel(with: invoice, in: context)
        model.sectionsObservable.subscribe(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: bag)
        
        model.balanceObservable.subscribe(onNext: { [unowned self](balance) in
            self.totalPaidLabel.text = balance.paid
            self.balanceLabel.text = balance.balance
        }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension PaymentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = model.sections[indexPath.section].rows[indexPath.row]
        item.performTap(indexPath: indexPath, tableView: tableView, in: self, model: model)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].headerTitle
    }
}
