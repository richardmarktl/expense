//
// Created by Richard Marktl on 2019-04-18.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CommonUI
import CoreData
import CoreDataExtensio
import RxSwift
import InvoiceBotSDK

/// MARK: -
/// Item to display the data in the cell
extension BudgetEntryItem: Filterable {
    func isFoundWithSearchString(searchString: String) -> Bool {
        return name.lowercased().contains(searchString)
    }
}

/// MARK: -
/// Helper to abstract the different variants off how we load the data from the database
struct BudgetEntryItemHelper {

    /// Loads all available offers
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func instancesObservable(in context: NSManagedObjectContext) -> Observable<[BudgetEntryItem]> {

        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return Observable.just(()).observeOn(background).flatMap { () -> Observable<[BudgetEntry]> in
            let predicate = NSPredicate.undeletedItem()
            return BudgetEntry.rxAllObjects(matchingPredicate: predicate, context: context)
        }.map { wallets in
            return wallets.map { BudgetEntryItem(defaultData: $0) }
        }.observeOn(MainScheduler.instance)
    }

    static func mapper(_ items: [BudgetEntryItem]) -> Section<UICollectionView> {
        let rows: [Row<UICollectionView>] = items.map({ (item) -> Row<UICollectionView> in
            let configRow: Row<UICollectionView> = GridRow<BudgetEntryCell, SelectBudgetEntryAction>(item: item, action: SelectBudgetEntryAction())
            return configRow
        })
        return Section(rows: rows)
    }
}

/// The wallets model is used to load and handle all the wallets objects.
class BudgetEntriesModel: SearchableModel<BudgetEntryItem, UICollectionView> {
    convenience init(searchObservable: Observable<String>, with context: NSManagedObjectContext) {
        // add the create wallet cell.
        let rows: [Row<UICollectionView>] = [
            GridRow<CreateWalletCell, CreateWalletAction>(item: ActionItem(title: ""), action: CreateWalletAction()),
        ]

        self.init(searchObservable: searchObservable,
                loadObservable: BudgetEntryItemHelper.instancesObservable(in: context),
                itemMapper: BudgetEntryItemHelper.mapper, defaultSections: [Section(rows: rows)], with: context
        )
    }
}

