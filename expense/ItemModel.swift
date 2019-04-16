//
//  ItemModel.swift
//  InVoice
//
//  Created by Georg Kitz on 17/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

/// Client Model
class ItemModel: DetailModel<Item> {
    
    /// Data model items that hold the values the user edits
    private let itemTitle: TextEntry
    private let description: TextEntry
    private let price: NumberEntry
    private let tax: NumberEntry
    private let number: TextEntry
    
    /// Observable that determines when to enable the save button, basically we just need a `description` to store an item
    override var saveEnabledObservable: Observable<Bool> {
        return description.value.asObservable().map({ (value) -> Bool in
            return !(value?.isEmpty ?? true)
        })
    }
    
    override var shouldAutoSelectFirstRowIfNewlyInserted: Bool {
        return item.title?.isEmpty ?? true
    }
    
    /// Inits the model
    ///
    /// - Parameters:
    ///   - item: if we get a template item we init it with the data of the template
    ///   - context: the context we operate on
    required init(item: Item, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [Section], in context: NSManagedObjectContext) {
        
        Locale.current.currencyCode.map(Currency.create).map(CurrencyLoader.update)
        
        itemTitle = TextEntry(titleForOrder: nil, orItem: item)
        description = TextEntry(descriptionForOrder: nil, orItem: item)
        price = NumberEntry(priceOf: nil, item: item)
        tax = NumberEntry(taxOf: nil, item: item)
        number = TextEntry(placeholder: "number", value: item.number)
        
        let rows: [ConfigurableRow] = [
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: itemTitle, action: FirstResponderActionTextFieldCell()),
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: description, action: FirstResponderActionTextViewCell()),
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: price, action: FirstResponderActionNumberCell()),
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: tax, action: FirstResponderActionNumberCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: number, action: FirstResponderActionTextFieldCell())
        ]
        
        super.init(item: item, storeChangesAutomatically: storeChangesAutomatically, deleteAutomatically: false, sections: [Section(rows: rows)], in: context)
        
        if storeChangesAutomatically {
            
            itemTitle.value.asObservable().subscribe(onNext: { (value) in
                item.title = value.databaseValue
            }).disposed(by: bag)
            
            description.value.asObservable().subscribe(onNext: { (value) in
                item.itemDescription = value.databaseValue
            }).disposed(by: bag)
            
            price.data.asObservable().subscribe(onNext: { (value) in
                item.price = value.asRounded()
            }).disposed(by: bag)
            
            tax.data.asObservable().subscribe(onNext: { (value) in
                item.tax = value
            }).disposed(by: bag)
            
            number.value.asObservable().subscribe(onNext: { (value) in
                item.number = value.databaseValue
            }).disposed(by: bag)
        }
        
        title = item.isInserted ? R.string.localizable.newItem() : R.string.localizable.updateItem()
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
    
    override func save() -> Item {
        if storeChangesAutomatically {
            
            item.isInserted ? Analytics.saveNewItem.logEvent() : Analytics.saveModifiedItem.logEvent()
            
            let saveContext = context
            _ = ItemRequest.upload(item).take(1).subscribe(onNext: { _ in
                try? saveContext.save()
            })
        }
        return super.save()
    }
    
    override func delete() {
        item.deletedTimestamp = Date()
        return super.delete()
    }
}
