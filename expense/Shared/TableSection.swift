//
//  TableSection.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

class TableSection: Equatable {
    
    static func == (lhs: TableSection, rhs: TableSection) -> Bool {
        return lhs === rhs
    }
    
    private var internalHeaderTitle: Variable<String?>
    private var internalFooterTitle: Variable<String?>
    
    var rows: [ConfigurableRow] = []
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
    
    init(rows: [ConfigurableRow], headerTitle: String? = nil, footerTitle: String? = nil) {
        self.internalHeaderTitle = Variable(headerTitle)
        self.internalFooterTitle = Variable(footerTitle)
        self.rows = rows
    }
    
    func insert(tableRow: ConfigurableRow, at idx: Int) {
        rows.insert(tableRow, at: idx)
    }
    
    func add(tableRow: ConfigurableRow) {
        rows.insert(tableRow, at: rows.count)
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
