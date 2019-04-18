//
//  Section.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

open class Section<T>: Equatable {

    public static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs === rhs
    }
    
    private var internalHeaderTitle: Variable<String?>
    private var internalFooterTitle: Variable<String?>

    public var rows: [Row<T>] = []
    public var headerTitle: String? {
        return rows.count == 0 ? nil : internalHeaderTitle.value
    }

    public var headerTitleUpdatedObservable: Observable<String?> {
        return internalHeaderTitle.asObservable()
    }

    public var footerTitle: String? {
        return rows.count == 0 ? nil : internalFooterTitle.value
    }

    public var footerTitleUpdatedObservable: Observable<String?> {
        return internalFooterTitle.asObservable()
    }

    public var changedObservable: Observable<Void> {
        return Observable.empty()
    }

    public init(rows: [Row<T>], headerTitle: String? = nil, footerTitle: String? = nil) {
        self.internalHeaderTitle = Variable(headerTitle)
        self.internalFooterTitle = Variable(footerTitle)
        self.rows = rows
    }

    public func row(at index: Int) -> Row<T>? {
        guard index >= 0 && index <= rows.count else {
            return nil
        }
        return rows[index]
    }

    public func insert(row: Row<T>, at idx: Int) {
        rows.insert(row, at: idx)
    }

    public func add(row: Row<T>) {
        rows.insert(row, at: rows.count)
    }

    public func delete(at idx: Int) {
        rows.remove(at: idx)
    }

    public func deleteAll() {
        rows.removeAll()
    }

    public func canBeReordered(at indexPath: IndexPath) -> Bool {
        return false
    }

    public func targetIndexPathForReorderFromRow(at sourceIndexPath: IndexPath, to targetIndexPath: IndexPath) -> IndexPath {
        return targetIndexPath
    }

    public func reorderRow(at sourceIndexPath: IndexPath, to destIndexPath: IndexPath) {
        let item = rows[sourceIndexPath.row]
        rows.remove(at: sourceIndexPath.row)
        rows.insert(item, at: destIndexPath.row)
    }

    public func updateHeader(to newHeader: String?) {
        internalHeaderTitle.value = newHeader
    }

    public func updateFooter(to newFooter: String?) {
        internalFooterTitle.value = newFooter
    }
}
