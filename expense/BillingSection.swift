//
//  BillingSection
//  InVoice
//
//  Created by Georg Kitz on 13/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import CoreData
import RxSwift

class BillingSection: Section {
    
    let discount: DiscountEntry
    
    private let bag = DisposeBag()
    var numberOfPayments: Int = 0
    
    init(job: Job, in context: NSManagedObjectContext) {
        
        discount = DiscountEntry(discountable: job)
        
        discount.data.asObservable().subscribe(onNext: { (discount) in
            job.discount = discount.value
            job.isDiscountAbsolute = discount.isAbsolute
        }).disposed(by: bag)
        
        discount.data.asObservable().skip(2).take(1).subscribe(onNext: { (discount) in
            Analytics.changeDiscount.logEvent(["absolute": discount.isAbsolute.asNSNumber])
        }).disposed(by: bag)
        
        var rows: [ConfigurableRow] = [
            TableRow<DiscountCell, FirstResponderActionDiscountCell>(item: discount, action: FirstResponderActionDiscountCell())
        ]
        
        if job is Invoice {
            rows.append(TableRow<ActionCell, PaymentsAction>(item: ActionItem(title: R.string.localizable.payments()), action: PaymentsAction()))
        }
        
        super.init(rows: rows, headerTitle: R.string.localizable.billingSection())
        
        if let invoice = job as? Invoice, let context = invoice.managedObjectContext {
            Payment.rxPayments(for: invoice, in: context).map({ (items) -> Int in
                return items.count
            }).subscribe(onNext: { [unowned self](value) in
                self.numberOfPayments = value
            }).disposed(by: bag)
        }
    }
}
