//
//  BusinessSettingsController.swift
//  InVoice
//
//  Created by Georg Kitz on 19.02.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import Horreum
import RxCocoa
import RxSwift
import CoreData
import SwiftRichString

class BusinessSettingsController: TableModelController<BusinessSettingsModel>, AutoScroller {
    
    /// Autoscroller
    var scrollViewDefaultInsets: UIEdgeInsets = .zero
    var scrollView: UIScrollView!
    var additionalHeight: CGFloat = 0
    
    private var childContext: NSManagedObjectContext = {
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = Horreum.instance!.mainContext
        return childContext
    }()
    
    override lazy var model: BusinessSettingsModel = {
        let invoiceDefaults = Defaults.currentInvoiceDefaults(in: childContext)
        let offerDefaults = Defaults.currentOfferDefaults(in: childContext)
        return BusinessSettingsModel(invoiceDefaults: invoiceDefaults, offerDefaults: offerDefaults, context: childContext)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = tableView
        
        tableView.register(R.nib.textViewCell)
        tableView.register(R.nib.textFieldCell)
        tableView.register(R.nib.numberCell)
        
        title = R.string.localizable.businessSettings()
        
        let closeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        _ = closeBarButtonItem.rx.tap.take(1).subscribe(onNext: { (_) in
            
        })
        navigationItem.leftBarButtonItem = closeBarButtonItem
        
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        _ = saveBarButtonItem.rx.tap.take(1).subscribe(onNext: {[weak self] (_) in
            self?.model.save()
        })
        navigationItem.rightBarButtonItem = saveBarButtonItem
        navigationItem.rightBarButtonItem?.makeStrong()
        
        _ = Observable.of(closeBarButtonItem.rx.tap.take(1), saveBarButtonItem.rx.tap.take(1))
            .merge()
            .take(1)
            .subscribe(onNext: { [weak self] (_) in
                self?.dismiss(animated: true)
            })
        
        model.footerUpdateObservable.subscribe(onNext: { (value) in
            let footer = self.tableView.footerView(forSection: value.0) as? TableFooterView
            self.tableView.beginUpdates()
            footer?.footerLabel?.attributedText = value.1.set(style: StyleGroup.headerFooterStyleGroup())
            self.tableView.endUpdates()
        }).disposed(by: bag)
        
        model.isValidObservable.subscribe(onNext: { [weak self] (valid) in
            self?.navigationItem.rightBarButtonItem?.isEnabled = valid
        }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardEvents(rx.viewWillDisappear.mapToVoid())
    }
}
