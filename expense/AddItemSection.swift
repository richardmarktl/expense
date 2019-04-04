//
//  AddItemSection.swift
//  InVoice
//
//  Created by Georg Kitz on 27/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

class AddItemSection: TableSection {
    
    private let bag = DisposeBag()
    private(set) var orders: [Order] = []
    
    private let changeSubject: ReplaySubject<Void> = ReplaySubject.create(bufferSize: 1)
    override var changedObservable: Observable<Void> {
        return changeSubject.asObservable()
    }
    
    init(job: Job) {
        
        let rows: [ConfigurableRow] = [
            TableRow<AddCell, AddItemAction>(item: AddItem(title: R.string.localizable.addItems(), image: R.image.add_item()!, automatedTestingType: .item), action: AddItemAction())
        ]
        
        super.init(rows: rows, headerTitle: R.string.localizable.items())
        
        CurrencyLoader.currentCurrencyObservable.subscribe(onNext: { [unowned self](data) in
            self.deleteAll()
            job.ordersTyped
                .asSorted()
                .enumerated().forEach({ (idx, item) in
                    self.add(order: item, at: IndexPath(row: idx, section: 0))
                })
            self.add(tableRow: rows[0])
            self.changeSubject.onNext(())
        }).disposed(by: bag)
    }
    
    func add(order: Order, at indexPath: IndexPath) {
        
        if order.sort == 0 && indexPath.row != 0 {
            order.sort = Int16(indexPath.row)
        }
        
        let row = TableRow<OrderItemCell, OrderItemAction>(item: OrderItem(defaultData: order), action: OrderItemAction())
        insert(tableRow: row, at: indexPath.row)
        orders.insert(order, at: indexPath.row)
        
        changeSubject.onNext(())
    }
    
    func update(order: Order, at indexPath: IndexPath) {
        delete(at: indexPath.row)
        orders.remove(at: indexPath.row)
        
        let row = TableRow<OrderItemCell, OrderItemAction>(item: OrderItem(defaultData: order), action: OrderItemAction())
        insert(tableRow: row, at: indexPath.row)
        orders.insert(order, at: indexPath.row)
        
        changeSubject.onNext(())
    }
    
    func remove(at indexPath: IndexPath) {
        delete(at: indexPath.row)
        orders.remove(at: indexPath.row)
        
        changeSubject.onNext(())
    }
    
    override func canBeReordered(at indexPath: IndexPath) -> Bool {
        return indexPath.row != rows.count - 1
    }
    
    override func targetIndexPathForReorderFromRow(at sourceIndexPath: IndexPath, to targetIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != targetIndexPath.section || targetIndexPath.row == rows.count - 1 {
            return sourceIndexPath
        }
        return targetIndexPath
    }
    
    override func reorderRow(at sourceIndexPath: IndexPath, to destIndexPath: IndexPath) {
        super.reorderRow(at: sourceIndexPath, to: destIndexPath)
        
        let order = orders[sourceIndexPath.row]
        orders.remove(at: sourceIndexPath.row)
        orders.insert(order, at: destIndexPath.row)
        
        orders.enumerated().forEach { (element) in
            element.element.sort = Int16(element.offset)
        }
        
        changeSubject.onNext(())
    }
    
    override func deleteAll() {
        super.deleteAll()
        orders.removeAll()
    }
}
