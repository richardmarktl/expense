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
    typealias TypedSection = TableSection<CollectionType>
    let bag = DisposeBag()
    let sectionsVariable: Variable<[TypedSection]> = Variable([])
    let context: NSManagedObjectContext
    
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
    
    func insert(tableRow: Row<CollectionType>, at indexPath: IndexPath) {
        sections[indexPath.section].insert(tableRow: tableRow, at: indexPath.row)
    }
    
    func delete(at indexPath: IndexPath) {
        sections[indexPath.section].delete(at: indexPath.row)
    }
    
    func canEdit(at indexPath: IndexPath) -> Bool {
        return false
    }
}
