//
//  TableModel.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class TableModel {
    
    let bag = DisposeBag()
    let sectionsVariable: Variable<[TableSection]> = Variable([])
    let context: NSManagedObjectContext
    
    var sections: [TableSection] {
        set {
            sectionsVariable.value = newValue
        }
        get {
            return sectionsVariable.value
        }
    }
    
    var sectionsObservable: Observable<[TableSection]> {
        return sectionsVariable.asObservable()
    }
    
    required init(with context: NSManagedObjectContext) {
        self.context = context
    }
    
    func insert(tableRow: ConfigurableRow, at indexPath: IndexPath) {
        sections[indexPath.section].insert(tableRow: tableRow, at: indexPath.row)
    }
    
    func delete(at indexPath: IndexPath) {
        sections[indexPath.section].delete(at: indexPath.row)
    }
    
    func canEdit(at indexPath: IndexPath) -> Bool {
        return false
    }
}
