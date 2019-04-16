//
//  ItemsModel.swift
//  InVoice
//
//  Created by Georg Kitz on 16/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

import Foundation
import RxSwift
import CoreData

/// MARK: -
/// Item to display the data in the cell
extension ItemItem: Filterable {
    
    func isFoundWithSearchString(searchString: String) -> Bool {
        return title.lowercased().contains(searchString)
    }
}

/// MARK: -
/// Select Client Action
class SelectItemAction: ProTapAction<ItemItem> {
    override func performTap(with rowItem: ItemItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        let itemCtr = ItemViewController.show(item: rowItem.value)
        Analytics.itemSelect.logEvent()
        ctr.present(itemCtr, animated: true)
    }
}

/// MARK: -
/// Helper to abstract the different variants off how we load the data from the database
struct ItemHelper {
    
    /// Loads all available offers
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func itemObservable(in context: NSManagedObjectContext) -> Observable<[ItemItem]> {
        
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return Observable.just(()).observeOn(background).flatMap {
            return Item.rxAllObjects(matchingPredicate: NSPredicate.undeletedItem(), sorted: [NSSortDescriptor(key: "title", ascending: true)], context: context)
        }.map {
            return $0.map { ItemItem(item: $0) }
        }.observeOn(MainScheduler.instance)
    }
    
    static func mapper(_ items: [ItemItem]) -> Section {
        
        let rows: [ConfigurableRow] = items.map({ (item) -> ConfigurableRow in
            let configRow: ConfigurableRow = TableRow<ItemCell, SelectItemAction>(item: item, action: SelectItemAction())
            return configRow
        })
        return Section(rows: rows)
    }
}

///// MARK: -
///// Model that combines the data loading + searching
class ItemsModel: SearchableTableModel<ItemItem> {
    convenience init(searchObservable: Observable<String>, with context: NSManagedObjectContext) {
        self.init(searchObservable: searchObservable, loadObservable: ItemHelper.itemObservable(in: context),
                  itemMapper: ItemHelper.mapper, defaultSections: [], with: context)
    }
}
