//
//  PaymentController.swift
//  InVoice
//
//  Created by Georg Kitz on 01/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreData
import RxSwift

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: ActionButton!
    @IBOutlet weak var saveButton: ActionButton!
    
    var payment: Payment?
    var invoice: Invoice!
    var context: NSManagedObjectContext!
    
    private let bag = DisposeBag()
    private var model: PaymentModel!
    private var lastSelectedItem: ConfigurableRow?
    
    var completionBlock: ((Payment) -> Void)?
    var removeBlock: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        tableView.register(R.nib.dateCell)
        tableView.register(R.nib.paymentTypeCell)
        
        model = PaymentModel(payment: payment, for: invoice, in: context)
        model.saveEnabledObservable.subscribe(onNext: { [unowned self] (enabled) in
            self.saveButton.button?.isEnabled = enabled
        }).disposed(by: bag)
        
        saveButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            Analytics.save.logEvent()
            
            let payment = self.model.save()
            if let completionBlock = self.completionBlock {
                completionBlock(payment)
            }
            
            self.dismiss(animated: true)
        }).disposed(by: bag)
        
        title = model.title
        
        navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] (_) in
            Analytics.cancel.logEvent()
            
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            self.dismiss(animated: true)
        }).disposed(by: bag)
        
        setupDeleteButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if model.payment == nil {
            tableView.delegate?.tableView!(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        }
    }
    
    private func setupDeleteButton() {
        
        deleteButton.title = model.deleteButtonTitle
        deleteButton.isHidden = model.isDeleteButtonHidden
        deleteButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            Analytics.delete.logEvent()
            
            if let removeBlock = self.removeBlock {
                removeBlock()
            } else {
                self.model.delete()
            }
            
            self.dismiss(animated: true)
        }).disposed(by: bag)
    }
}

// MARK: - UITableView
extension PaymentViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        if let lastItem = lastSelectedItem, item.identifier != lastItem.identifier {
            lastItem.rewindAction(tableView: tableView, in: self, model: model)
            lastSelectedItem = nil
        }
        
        lastSelectedItem = item
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].headerTitle
    }
}
