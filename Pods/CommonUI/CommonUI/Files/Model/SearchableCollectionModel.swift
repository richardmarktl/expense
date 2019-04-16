//
// Created by Richard Marktl on 2019-04-15.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//


import UIKit
import RxSwift
import CoreData

class SearchableCollectionModel<ItemType: Filterable>: CollectionModel {

    /// Model that combines the data loading + searching
    ///
    /// - Parameters:
    ///   - searchObservable: observable which changes when the searchstring changes
    ///   - loadObservable: data load observable
    public init(searchObservable: Observable<String>,
                loadObservable: Observable<[ItemType]>,
                itemMapper: @escaping (([ItemType]) -> Section<UICollectionView>),
                defaultSections: [Section<UICollectionView>], with context: NSManagedObjectContext) {
        super.init(with: context)

        Observable.combineLatest(loadObservable, searchObservable) { (obs, obs2) in
            return (obs, obs2)
        }.map { (items, searchString) -> [ItemType] in
            // the string is trimmed because it is possible that a text field returns non visible characters
            let trimmedSearchString = searchString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
            if trimmedSearchString.count == 0 {
                return items
            }

            return items.filter({ (item) -> Bool in
                return item.isFoundWithSearchString(searchString: trimmedSearchString)
            })

        }.map { (items) in

            var sections = defaultSections
            sections.append(itemMapper(items))
            return sections

        }.bind(to: sectionsVariable).disposed(by: bag)
    }

    public required init(with context: NSManagedObjectContext) {
        fatalError()
    }
}