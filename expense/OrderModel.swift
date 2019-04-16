//
//  OrderModel.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class OrderModel: DetailModel<Order> {
    
    /// Data model items that hold the values the user edits
    private let orderTitle: TextEntry
    private let description: TextEntry
    private let quantity: NumberEntry
    private let price: NumberEntry
    private let discount: DiscountEntry
    private let tax: NumberEntry
    private let number: TextEntry
    
    override var saveEnabledObservable: Observable<Bool> {
        return orderTitle.value.asObservable().map({ (value) -> Bool in
            return !(value?.isEmpty ?? true)
        })
    }
    
    override var shouldAutoSelectFirstRowIfNewlyInserted: Bool {
        return item.template == nil
    }
    
    var totalObservable: Observable<String> {
        let currencyCode = item.item?.currency
        return Observable.combineLatest(quantity.data.asObservable(), price.data.asObservable(), discount.data.asObservable(), tax.data.asObservable()) { (obs1, obs2, obs3, obs4) in
            return (obs1, obs2, obs3, obs4)
        }.map { (items) -> String in
            
                let quantity = items.0
                let price = items.1
                let discount = items.2
                let tax = items.3
                
                var total = quantity * price
                if discount.value != NSDecimalNumber.zero && discount.value != NSDecimalNumber.notANumber {
                    if discount.isAbsolute {
                        total -= discount.value
                    } else {
                        total = total * (1 - discount.value / 100)
                    }
                }
                
                if tax != NSDecimalNumber.zero && tax != NSDecimalNumber.notANumber {
                    total = total * (1 + tax / 100)
                }
                
            return total.asCurrency(currencyCode: currencyCode)
        }
    }
    
    required init(item: Order, in context: NSManagedObjectContext) {
        
        orderTitle = TextEntry(titleForOrder: item, orItem: item.template)
        description = TextEntry(descriptionForOrder: item, orItem: item.template)
        quantity = NumberEntry(quantityOf: item)
        price = NumberEntry(priceOf: item, item: item.template)
        discount = DiscountEntry(discountable: item)
        tax = NumberEntry(taxOf: item, item: item.template)
        number = TextEntry(numberForOrder: item, orItem: item.template)
        
        var rows: [ConfigurableRow] = [
            TableRow<TextViewCell, FirstResponderActionTextFieldCell>(item: orderTitle, action: FirstResponderActionTextFieldCell()),
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: description, action: FirstResponderActionTextViewCell()),
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: quantity, action: FirstResponderActionNumberCell()),
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: price, action: FirstResponderActionNumberCell()),
            TableRow<DiscountCell, FirstResponderActionDiscountCell>(item: discount, action: FirstResponderActionDiscountCell()),
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: tax, action: FirstResponderActionNumberCell())
        ]
        
        if item.template == nil {
            rows.append(TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: number, action: FirstResponderActionTextFieldCell()))
        }
        
        super.init(item: item, storeChangesAutomatically: false, deleteAutomatically: false, sections: [Section(rows: rows)], in: context)
        
        title = item.isInserted ? R.string.localizable.newItem() : R.string.localizable.updateItem()
        isDeleteButtonHidden = item.item == nil
        deleteButtonTitle = R.string.localizable.remove()
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
    
    required init(item: Order, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [Section], in context: NSManagedObjectContext) {
        fatalError()
    }
    
    override func save() -> Order {
        
        if item.template == nil {
            let newItem = Item.create(in: context)
            newItem.title = orderTitle.value.value.databaseValue
            newItem.itemDescription = description.value.value.databaseValue
            newItem.price = price.value
            newItem.tax = tax.value
            newItem.number = number.value.value.databaseValue
            item.template = newItem
        }
        
        item.title = orderTitle.value.value.databaseValue
        item.itemDescription = description.value.value.databaseValue
        item.quantity = quantity.value
        item.price = price.value.asRounded()
        item.discount = discount.value.value
        item.isDiscountAbsolute = discount.value.isAbsolute
        item.tax = tax.value
        item.number = number.value.value.databaseValue
        
        item.calculateTotal()
        
        return super.save()
    }
    
    override func delete() {
        
        // this is interesting, if the item wasn't stored yet,
        // we can simply remove it from the context, imagine we just
        // create a new invoice and remove the order again, without ever storing
        // the invoice before.
        if item.remoteId == 0 && item.isInserted {
            
            if let template = item.template, template.remoteId == 0 && template.isInserted {
                context.delete(template)
            }
            
            context.delete(item)
        } else {
            item.deletedTimestamp = Date()
            item.item = nil
            item.template = nil
        }
        super.delete()
    }
}
