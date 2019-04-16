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

/// Client Model
class ClientModel: DetailModel<Client> {

    private let name: TextEntry
    private let email: TextEntry
    private let phone: TextEntry
    private let address: TextEntry
    private let taxId: TextEntry
    private let number: TextEntry
    
    override var saveEnabledObservable: Observable<Bool> {
       return Observable.combineLatest(name.value.asObservable(), email.isValidObservable, phone.isValidObservable) { (nameEntry, emailValid, phoneValid) -> Bool in
            return !(nameEntry?.isEmpty ?? true) && emailValid && phoneValid
        }
    }
    
    override var shouldAutoSelectFirstRowIfNewlyInserted: Bool {
        return item.name?.isEmpty ?? true
    }
    
    required init(item: Client, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [Section], in context: NSManagedObjectContext) {
        
        name = TextEntry(placeholder: R.string.localizable.name(), value: item.name, keyboardType: .default, textContentType: .name,
                         autoCapitalizationType: UITextAutocapitalizationType.words)
        email = TextEntry(placeholder: R.string.localizable.email(), value: item.email, keyboardType: .emailAddress, textContentType: .emailAddress, validator: DefaultValidators.emailValidator)
        phone = TextEntry(placeholder: R.string.localizable.phone(), value: item.phone, keyboardType: .phonePad, textContentType: .telephoneNumber, validator: DefaultValidators.phoneValidator, enteredTextModifier: TextEntry.TextModifier.removeWithespace)
        address = TextEntry(placeholder: R.string.localizable.address(), value: item.address, textContentType: .fullStreetAddress,
                            autoCapitalizationType: UITextAutocapitalizationType.words)
        taxId = TextEntry(placeholder: R.string.localizable.taxId(), value: item.taxId, autoCapitalizationType: UITextAutocapitalizationType.allCharacters)
        number = TextEntry(placeholder: "number", value: item.number, autoCapitalizationType: UITextAutocapitalizationType.allCharacters)
        
        let rows: [ConfigurableRow] = [
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: name, action: FirstResponderActionTextFieldCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: email, action: FirstResponderActionTextFieldCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: phone, action: FirstResponderActionTextFieldCell()),
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: address, action: FirstResponderActionTextViewCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: taxId, action: FirstResponderActionTextFieldCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: number, action: FirstResponderActionTextFieldCell()),
        ]
        
        super.init(item: item, storeChangesAutomatically: storeChangesAutomatically, deleteAutomatically: deleteAutomatically, sections: [Section(rows: rows)], in: context)
        
        if storeChangesAutomatically {
            name.value.asObservable().subscribe(onNext: { item.name = $0.databaseValue }).disposed(by: bag)
            email.value.asObservable().subscribe(onNext: { item.email = $0.databaseValue }).disposed(by: bag)
            phone.value.asObservable().subscribe(onNext: { item.phone = $0.databaseValue.removeWhitespaces }).disposed(by: bag)
            address.value.asObservable().subscribe(onNext: { item.address = $0.databaseValue }).disposed(by: bag)
            taxId.value.asObservable().subscribe(onNext: { item.taxId = $0.databaseValue }).disposed(by: bag)
            number.value.asObservable().subscribe(onNext: { item.number = $0.databaseValue }).disposed(by: bag)
        }
        
        title = item.isInserted ? R.string.localizable.newClient() : R.string.localizable.updateClient()
        // set the delete hidden state if the is not storeChangesAutomatically then set it to false.
        // if we create a new contact from the contact picker, it has no jobs assigned, thus we hide the remove button too.
        isDeleteButtonHidden = storeChangesAutomatically ? item.isInserted : item.typedJobs.count == 0
        deleteButtonTitle = storeChangesAutomatically ? R.string.localizable.delete() : R.string.localizable.remove()
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
    
    override func save() -> Client {
        
        if !storeChangesAutomatically {
            
            item.name = name.value.value.databaseValue
            item.email = email.value.value.databaseValue
            item.phone = phone.value.value.databaseValue.removeWhitespaces
            item.address = address.value.value.databaseValue
            item.taxId = taxId.value.value.databaseValue
            item.number = number.value.value.databaseValue
            item.isActive = true
            
        } else {
            
            item.isInserted ? Analytics.saveNewClient.logEvent() : Analytics.saveModifiedItem.logEvent()
            
            let saveContext = context
            _ = ClientRequest.upload(item).take(1).subscribe(onNext: { _ in
                try? saveContext.save()
            })
        }
        
        return super.save()
    }
    
    override func delete() {
        
        if deleteAutomatically {
            item.isActive = false
        }
        
        if storeChangesAutomatically {
            try? context.save()
        }
    }
}
