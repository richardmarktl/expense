//
//  TaxModel.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class TaxModel: DetailModel<Account> {
    
    let tax: NumberEntry
    
    override var saveEnabledObservable: Observable<Bool> {
        return Observable.just(true)
    }
    
    override var shouldAutoSelectFirstRowIfNewlyInserted: Bool {
        return tax.value == NSDecimalNumber.zero
    }
    
    required init(item: Account, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [TableSection], in context: NSManagedObjectContext) {
        
        tax = NumberEntry(title: R.string.localizable.taxes(), defaultData: item.tax!, validatorType: .tax)
        let rows: [ConfigurableRow] = [
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: tax, action: FirstResponderActionNumberCell())
        ]
        let sections = [TableSection(rows: rows)]
        
        super.init(item: item, storeChangesAutomatically: true, deleteAutomatically: true, sections: sections, in: context)
        title = R.string.localizable.defaultTaxes()
        tax.data.asObservable().subscribe(onNext: {
            item.tax = $0
        }).disposed(by: bag)
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
