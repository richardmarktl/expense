//
//  PaymentDetailsModel.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class PaymentDetailsModel: DetailModel<Account> {
    
    let paymentDetails: TextEntry
    
    override var saveEnabledObservable: Observable<Bool> {
        return Observable.just(true)
    }
    
    override var shouldAutoSelectFirstRowIfNewlyInserted: Bool {
        return paymentDetails.value.value?.isEmpty ?? false
    }
    
    required init(item: Account, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [Section], in context: NSManagedObjectContext) {
        
        paymentDetails = TextEntry(placeholder: R.string.localizable.paymentDetailsTitle(), value: item.paymentDetails,
                                   autoCapitalizationType: UITextAutocapitalizationType.sentences)
        let rows: [ConfigurableRow] = [
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: paymentDetails, action: FirstResponderActionTextViewCell())
        ]
        let sections = [Section(rows: rows)]
        
        super.init(item: item, storeChangesAutomatically: true, deleteAutomatically: true, sections: sections, in: context)
        title = R.string.localizable.paymentDetailsTitle()
        paymentDetails.value.asObservable().subscribe(onNext: { item.paymentDetails = $0.databaseValue }).disposed(by: bag)
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError("init(with:) has not been implemented")
    }
    
    override func save() -> Account {
        
        let saveContext = context
        _ = AccountRequest.upload(item).take(1).subscribe(onNext: { _ in
            try? saveContext.save()
        })
        
        return super.save()
    }
}
