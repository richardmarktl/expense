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

open class Model<CollectionType> {
    public typealias TypedSection = Section<CollectionType>
    public let bag = DisposeBag()
    public let context: NSManagedObjectContext

    public let sectionsVariable: Variable<[TypedSection]> = Variable([])
    public var lastSelectedRow: Row<CollectionType>?

    public var sections: [TypedSection] {
        set {
            sectionsVariable.value = newValue
        }
        get {
            return sectionsVariable.value
        }
    }

    public var sectionsObservable: Observable<[TypedSection]> {
        return sectionsVariable.asObservable()
    }

    public required init(with context: NSManagedObjectContext) {
        self.context = context
    }

    public func numberOfSections() -> Int {
        return sections.count
    }

    public func numberOfRows(in section: Int) -> Int {
        guard section >= 0 && section < sections.count else {
            return 0
        }
        return sections[section].rows.count
    }

    public func section(at section: Int) -> TypedSection? {
        guard section >= 0 && section < sections.count else {
            return nil
        }
        return sections[section]
    }

    public func row(at indexPath: IndexPath) -> Row<CollectionType>? {
        guard let section = section(at: indexPath.section) else {
            return nil
        }
        return section.row(at: indexPath.row)
    }

    public func insert(row: Row<CollectionType>, at indexPath: IndexPath) {
        guard let section = section(at: indexPath.section) else {
            return
        }
        section.insert(row: row, at: indexPath.row)
    }

    public func delete(at indexPath: IndexPath) {
        guard let section = section(at: indexPath.section) else {
            return
        }
        section.delete(at: indexPath.row)
    }

    public func canEdit(at indexPath: IndexPath) -> Bool {
        return false
    }

    public func performTap(at indexPath: IndexPath, sender: CollectionType, in controller: UIViewController) {
        guard let row = row(at: indexPath) else {
            return
        }

        row.performTap(indexPath: indexPath, sender: sender, in: controller, model: self)

        if let lastItem = lastSelectedRow, row.identifier != lastItem.identifier {
            rewindAction(row: lastItem, sender: sender, in: controller)
        }

        lastSelectedRow = row
    }

    public func rewindAction(row: Row<CollectionType>, sender: CollectionType, in controller: UIViewController) {
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

    public func rewindLastAction(sender: CollectionType, in controller: UIViewController) {
        if let lastRow = lastSelectedRow {
            rewindAction(row: lastRow, sender: sender, in: controller)
        }
    }
}
