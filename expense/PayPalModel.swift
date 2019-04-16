//
//  PayPalModel.swift
//  InVoice
//
//  Created by Richard Marktl on 16.04.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import EmailValidator

class PayPalModel: DetailModel<Account> {
    
    let paypalId: TextEntry
    var paypalDisposable: Disposable  // this variable is used to dispose the after the cancelling.
    
    override var saveEnabledObservable: Observable<Bool> {
        return Observable.combineLatest(paypalId.value.asObservable(), paypalId.isValidObservable, resultSelector: { (data, isValid) -> Bool in
            let isEmpty = data?.isEmpty ?? true
            return !isEmpty && isValid
        })
    }
    
    override var shouldAutoSelectFirstRowIfNewlyInserted: Bool {
        return paypalId.value.value?.isEmpty ?? false
    }
    
    override var shouldShowCancelWarning: Bool {
        return false
    }
    
    required init(item: Account, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [Section], in context: NSManagedObjectContext) {
        
        paypalId = TextEntry(
            placeholder: R.string.localizable.paypalId(),
            value: item.paypalId,
            keyboardType: UIKeyboardType.emailAddress,
            textContentType: UITextContentType.emailAddress,
            validator: DefaultValidators.emailValidator
        )
        
        let rows: [ConfigurableRow] = [
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: paypalId, action: FirstResponderActionTextFieldCell())
        ]
        let sections = [Section(rows: rows)]
        paypalDisposable = paypalId.value.asObservable().subscribe(onNext: {
            item.paypalId = $0.databaseValue
        })
        
        super.init(item: item, storeChangesAutomatically: true, deleteAutomatically: true, sections: sections, in: context)
        title = R.string.localizable.paypalSetup()
        paypalDisposable.disposed(by: bag)
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
