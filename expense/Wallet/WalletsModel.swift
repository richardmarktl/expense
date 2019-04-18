//
// Created by Richard Marktl on 2019-04-11.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import Crashlytics
import InvoiceBotSDK
import CommonUI

/// MARK: -
/// Item to display the data in the cell
extension WalletItem: Filterable {
    func isFoundWithSearchString(searchString: String) -> Bool {
        return name.lowercased().contains(searchString)
    }
}

/// MARK: -
/// Helper to abstract the different variants off how we load the data from the database
struct WalletItemHelper {

    /// Loads all available offers
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func instancesObservable(in context: NSManagedObjectContext) -> Observable<[WalletItem]> {

        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return Observable.just(()).observeOn(background).flatMap { () -> Observable<[BudgetWallet]> in
            let predicate = NSPredicate.undeletedItem()
            return BudgetWallet.rxAllObjects(matchingPredicate: predicate, context: context)
        }.map { wallets in
            return wallets.map { WalletItem(defaultData: $0) }
        }.observeOn(MainScheduler.instance)
    }

    static func mapper(_ items: [WalletItem]) -> Section<UICollectionView> {
        let rows: [Row<UICollectionView>] = items.map({ (item) -> Row<UICollectionView> in
            let configRow: Row<UICollectionView> = GridRow<WalletCell, SelectWalletAction>(item: item, action: SelectWalletAction())
            return configRow
        })
        return Section(rows: rows)
    }
}


/// The wallets model is used to load and handle all the wallets objects.
class WalletsModel: SearchableModel<WalletItem, UICollectionView> {
    convenience init(searchObservable: Observable<String>, with context: NSManagedObjectContext) {
        // add the create wallet cell.
        let rows: [Row<UICollectionView>] = [
            GridRow<CreateWalletCell, CreateWalletAction>(item: ActionItem(title: ""), action: CreateWalletAction()),
        ]

        self.init(searchObservable: searchObservable,
                loadObservable: WalletItemHelper.instancesObservable(in: context),
                itemMapper: WalletItemHelper.mapper, defaultSections: [Section(rows: rows)], with: context
        )
    }
}
