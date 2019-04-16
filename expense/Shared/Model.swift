//
//  Model.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class Model<CollectionType> {
    typealias TypedSection = Section<CollectionType>
    let bag = DisposeBag()
    let context: NSManagedObjectContext

    let sectionsVariable: Variable<[TypedSection]> = Variable([])
    var lastSelectedRow: Row<CollectionType>?

    var sections: [TypedSection] {
        set {
            sectionsVariable.value = newValue
        }
        get {
            return sectionsVariable.value
        }
    }

    var sectionsObservable: Observable<[TypedSection]> {
        return sectionsVariable.asObservable()
    }

    required init(with context: NSManagedObjectContext) {
        self.context = context
    }

    func numberOfSections() -> Int {
        return sections.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard section >= 0 && section < sections.count else {
            return 0
        }
        return sections[section].rows.count
    }

    func section(at section: Int) -> TypedSection? {
        guard section >= 0 && section < sections.count else {
            return nil
        }
        return sections[section]
    }

    func row(at indexPath: IndexPath) -> Row<CollectionType>? {
        guard let section = section(at: indexPath.section) else {
            return nil
        }
        return section.row(at: indexPath.row)
    }

    func insert(row: Row<CollectionType>, at indexPath: IndexPath) {
        guard let section = section(at: indexPath.section) else {
            return
        }
        section.insert(row: row, at: indexPath.row)
    }

    func delete(at indexPath: IndexPath) {
        guard let section = section(at: indexPath.section) else {
            return
        }
        section.delete(at: indexPath.row)
    }

    func canEdit(at indexPath: IndexPath) -> Bool {
        return false
    }

    func performTap(at indexPath: IndexPath, sender: CollectionType, in controller: UIViewController) {
        guard let row = row(at: indexPath) else {
            return
        }

        row.performTap(indexPath: indexPath, sender: sender, in: controller, model: self)

        if let lastItem = lastSelectedRow, row.identifier != lastItem.identifier {
            rewindAction(row: lastItem, sender: sender, in: controller)
        }

        lastSelectedRow = row
    }

    func rewindAction(row: Row<CollectionType>, sender: CollectionType, in controller: UIViewController) {
        guard let indexPath = row.indexPath else {
            return
        }

        row.indexPath = nil

        var index = NSNotFound
        if let section = section(at: indexPath.section) {
            section.rows.enumerated().forEach { (idx, item) in
                if item.identifier == row.identifier {
                    index = idx
                }
            }
        }

        if index == NSNotFound {
            return
        }

        let newIndexPath = IndexPath(row: index, section: indexPath.section)
        row.rewindAction(indexPath: newIndexPath, sender: sender, in: controller, model: self)
    }

    func rewindLastAction(sender: CollectionType, in controller: UIViewController) {
        if let lastRow = lastSelectedRow {
            rewindAction(row: lastRow, sender: sender, in: controller)
        }
    }
}
