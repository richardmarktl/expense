//
//  BudgetCategoryModel.swift
//  expense
//
// Created by Richard Marktl on 2019-04-24.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData
import Crashlytics
import InvoiceBotSDK
import CommonUI


class BudgetCategoryModel: DetailModel<BudgetCategory, UITableView> {

    /// Data model items that hold the values the user edits
    private let name: TextEntry
    private let description: TextEntry

    /// Observable that determines when to enable the save button, basically we just need a `description` to store an item
    override var saveEnabledObservable: Observable<Bool> {
        return name.value.asObservable().map({ (value) -> Bool in
            return !(value?.isEmpty ?? true)
        })
    }

    override var shouldAutoSelectFirstRowIfNewlyInserted: Bool {
        return item.name?.isEmpty ?? true
    }

    /// Inits the model
    ///
    /// - Parameters:
    ///   - item: if we get a template item we init it with the data of the template
    ///   - context: the context we operate on
    required init(item: BudgetCategory, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [Section<UITableView>], in context: NSManagedObjectContext) {
        // Locale.current.currencyCode.map(Currency.create).map(CurrencyLoader.update)

        name = TextEntry(placeholder: "Name", value: item.name)
        description = TextEntry(placeholder: "Description", value: item.categoryDescription)

        let rows: [Row<UITableView>] = [
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: name, action: FirstResponderActionTextFieldCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: description, action: FirstResponderActionTextFieldCell()),
        ]

        super.init(item: item, storeChangesAutomatically: storeChangesAutomatically, deleteAutomatically: false, sections: [Section(rows: rows)], in: context)

        if storeChangesAutomatically {

            name.value.asObservable().subscribe(onNext: { (value) in
                item.name = value.databaseValue
            }).disposed(by: bag)

            description.value.asObservable().subscribe(onNext: { (value) in
                item.categoryDescription = value.databaseValue
            }).disposed(by: bag)
        }

        // TODO: add strings
        title = "New Category" //  item.isInserted ? R.string.localizable.newItem() : R.string.localizable.updateItem()
    }

    required init(with context: NSManagedObjectContext) {
        fatalError()
    }

    override func save() -> BudgetCategory {
        if storeChangesAutomatically {

            // TODO: add analytics
            item.isInserted ? Analytics.saveNewItem.logEvent() : Analytics.saveModifiedItem.logEvent()

//            let saveContext = context
//            _ = ItemRequest.upload(item).take(1).subscribe(onNext: { _ in
//                try? saveContext.save()
//                        })
        }
        return super.save()
    }

    override func delete() {
        item.deletedTimestamp = Date()
        return super.delete()
    }
}
