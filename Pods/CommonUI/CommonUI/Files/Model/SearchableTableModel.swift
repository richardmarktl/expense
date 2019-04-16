//
//  SearchableTableModel.swift
//  InVoice
//
//  Created by Georg Kitz on 16/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

public protocol Filterable {
    func isFoundWithSearchString(searchString: String) -> Bool
}

public class SearchableTableModel<ItemType: Filterable>: TableModel {
    
    /// Model that combines the data loading + searching
    ///
    /// - Parameters:
    ///   - searchObservable: observable which changes when the searchstring changes
    ///   - loadObservable: data load observable
    public init(searchObservable: Observable<String>, loadObservable: Observable<[ItemType]>, itemMapper: @escaping (([ItemType]) -> Section<UITableView>),
         defaultSections: [Section<UITableView>], with context: NSManagedObjectContext) {
        
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
