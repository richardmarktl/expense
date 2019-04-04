//
//  InvoiceFilteredController.swift
//  InVoice
//
//  Created by Georg Kitz on 11/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum
import RxSwift

class InvoiceFilteredController: JobsViewController {
    
    override var nibName: String? {
        return R.nib.invoiceReusableController.name
    }
    
    override var nibBundle: Bundle? {
        return R.nib.invoiceReusableController.bundle
    }
    
    init() {
        super.init(nibName: R.nib.invoiceReusableController.name, bundle: R.nib.invoiceReusableController.bundle)
        model = JobItemModel(searchObservable: Observable.just(""), loadObservable: JobItemObservables.invoiceObservable(in: Horreum.instance!.mainContext))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.invoiceReusableCell)
    }
}
