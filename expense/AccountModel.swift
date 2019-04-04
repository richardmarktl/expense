//
//  ClientModel.swift
//  InVoice
//
//  Created by Georg Kitz on 19/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import EmailValidator

/// Account Model
class AccountModel: DetailModel<Account> {
    
    private let name: TextEntry
    private let email: TextEntry
    private let website: TextEntry
    private let phone: TextEntry
    private let address: TextEntry
    private let taxId: TextEntry
    
    override var saveEnabledObservable: Observable<Bool> {
        return Observable.combineLatest(
            name.value.asObservable(),
            email.isValidObservable,
            phone.isValidObservable,
            website.isValidObservable
        ) { (nameEntry, emailValid, phoneValid, websiteValid) -> Bool in
            return !(nameEntry?.isEmpty ?? true) && emailValid && phoneValid && websiteValid
        }
    }
    
    override var shouldAutoSelectFirstRowIfNewlyInserted: Bool {
        return item.name?.isEmpty ?? true
    }
    
    required init(item: Account, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [TableSection], in context: NSManagedObjectContext) {
        
        name = TextEntry(placeholder: R.string.localizable.name(), value: item.name, keyboardType: .default,
                         textContentType: .name, autoCapitalizationType: UITextAutocapitalizationType.words)
        email = TextEntry(placeholder: R.string.localizable.email(), value: item.email, keyboardType: .emailAddress, textContentType: .emailAddress, validator: DefaultValidators.emailValidator)
        website = TextEntry(placeholder: R.string.localizable.website(), value: item.website, keyboardType: .URL, textContentType: .URL, validator: DefaultValidators.websiteValidator) 
        phone = TextEntry(placeholder: R.string.localizable.phone(), value: item.phone, keyboardType: .phonePad, textContentType: .telephoneNumber, validator: DefaultValidators.phoneValidator, enteredTextModifier: TextEntry.TextModifier.removeWithespace)
        address = TextEntry(placeholder: R.string.localizable.address(), value: item.address,
                            textContentType: .fullStreetAddress, autoCapitalizationType: UITextAutocapitalizationType.words)
        taxId = TextEntry(placeholder: R.string.localizable.taxId(), value: item.taxId, autoCapitalizationType: UITextAutocapitalizationType.allCharacters)
        
        let rows: [ConfigurableRow] = [
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: name, action: FirstResponderActionTextFieldCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: email, action: FirstResponderActionTextFieldCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: website, action: FirstResponderActionTextFieldCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: phone, action: FirstResponderActionTextFieldCell()),
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: address, action: FirstResponderActionTextViewCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: taxId, action: FirstResponderActionTextFieldCell())
        ]
        
        super.init(item: item, storeChangesAutomatically: storeChangesAutomatically, deleteAutomatically: deleteAutomatically, sections: [TableSection(rows: rows)], in: context)
        
        if storeChangesAutomatically {
            name.value.asObservable().subscribe(onNext: { item.name = $0.databaseValue }).disposed(by: bag)
            email.value.asObservable().subscribe(onNext: { item.email = $0 .databaseValue}).disposed(by: bag)
            website.value.asObservable().subscribe(onNext: { item.website = $0.databaseValue }).disposed(by: bag)
            phone.value.asObservable().subscribe(onNext: { item.phone = $0.databaseValue }).disposed(by: bag)
            address.value.asObservable().subscribe(onNext: { item.address = $0.databaseValue }).disposed(by: bag)
            taxId.value.asObservable().subscribe(onNext: { item.taxId = $0.databaseValue }).disposed(by: bag)
        }
        
        title = R.string.localizable.businessDetails()
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
    
    override func save() -> Account {
            
        let saveContext = context
        _ = AccountRequest.upload(item).take(1).subscribe(onNext: { _ in
            try? saveContext.save()
        })
        
        return super.save()
    }
    
    override func delete() {
        //AN ACCOUNT CAN'T BE DELETED
    }
}
