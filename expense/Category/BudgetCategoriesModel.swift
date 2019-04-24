//
// Created by Richard Marktl on 2019-04-24.
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
extension BudgetCategoryItem: Filterable {
    func isFoundWithSearchString(searchString: String) -> Bool {
        return name.lowercased().contains(searchString)
    }
}

/// MARK: -
/// Helper to abstract the different variants off how we load the data from the database
struct BudgetCategoryItemHelper {

    /// Loads all available offers
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func instancesObservable(in context: NSManagedObjectContext) -> Observable<[BudgetCategoryItem]> {
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return Observable.just(()).observeOn(background).flatMap { () -> Observable<[BudgetCategory]> in
            let predicate = NSPredicate.undeletedItem()
            return BudgetCategory.rxAllObjects(matchingPredicate: predicate, context: context)
        }.map { wallets in
            return wallets.map {
                BudgetCategoryItem(defaultData: $0)
            }
        }.observeOn(MainScheduler.instance)
    }

    static func mapper(_ items: [BudgetCategoryItem]) -> Section<UICollectionView> {
        let rows: [Row<UICollectionView>] = items.map({ (item) -> Row<UICollectionView> in
            let configRow: Row<UICollectionView> = GridRow<BudgetCategoryCell, SelectBudgetCategoryAction>(
                    item: item,
                    action: SelectBudgetCategoryAction()
            )
            return configRow
        })
        return Section(rows: rows)
    }
}

/// The wallets model is used to load and handle all the wallets objects.
class BudgetCategoriesModel: SearchableModel<BudgetCategoryItem, UICollectionView> {
    convenience init(searchObservable: Observable<String>, with context: NSManagedObjectContext) {
        // add the create wallet cell.
        let rows: [Row<UICollectionView>] = [
            GridRow<CreateWalletCell, CreateBudgetCategoryAction>(
                    item: ActionItem(title: "+ Add Category"),
                    action: CreateBudgetCategoryAction()
            ),
        ]

        self.init(searchObservable: searchObservable,
                loadObservable: BudgetCategoryItemHelper.instancesObservable(in: context),
                itemMapper: BudgetCategoryItemHelper.mapper, defaultSections: [Section(rows: rows)], with: context
        )
    }
}

