//
//  Section.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

class Section<T>: Equatable {
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs === rhs
    }
    
    private var internalHeaderTitle: Variable<String?>
    private var internalFooterTitle: Variable<String?>
    
    var rows: [Row<T>] = []
    var headerTitle: String? {
        return rows.count == 0 ? nil : internalHeaderTitle.value
    }
    
    var headerTitleUpdatedObservable: Observable<String?> {
        return internalHeaderTitle.asObservable()
    }
    
    var footerTitle: String? {
        return rows.count == 0 ? nil : internalFooterTitle.value
    }
    
    var footerTitleUpdatedObservable: Observable<String?> {
        return internalFooterTitle.asObservable()
    }
    
    var changedObservable: Observable<Void> {
        return Observable.empty()
    }
    
    init(rows: [Row<T>], headerTitle: String? = nil, footerTitle: String? = nil) {
        self.internalHeaderTitle = Variable(headerTitle)
        self.internalFooterTitle = Variable(footerTitle)
        self.rows = rows
    }

    func row(at index: Int) -> Row<T>? {
        guard index >= 0 && index <= rows.count else {
            return nil
        }
        return rows[index]
    }

    func insert(row: Row<T>, at idx: Int) {
        rows.insert(row, at: idx)
    }
    
    func add(row: Row<T>) {
        rows.insert(row, at: rows.count)
    }
    
    func delete(at idx: Int) {
        rows.remove(at: idx)
    }
    
    func deleteAll() {
        rows.removeAll()
    }
    
    func canBeReordered(at indexPath: IndexPath) -> Bool {
        return false
    }
    
    func targetIndexPathForReorderFromRow(at sourceIndexPath: IndexPath, to targetIndexPath: IndexPath) -> IndexPath {
        return targetIndexPath
    }
    
    func reorderRow(at sourceIndexPath: IndexPath, to destIndexPath: IndexPath) {
        let item = rows[sourceIndexPath.row]
        rows.remove(at: sourceIndexPath.row)
        rows.insert(item, at: destIndexPath.row)
    }
    
    func updateHeader(to newHeader: String?) {
        internalHeaderTitle.value = newHeader
    }
    
    func updateFooter(to newFooter: String?) {
        internalFooterTitle.value = newFooter
    }
}
