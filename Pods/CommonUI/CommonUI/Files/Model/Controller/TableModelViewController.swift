//
//  TableModelViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 16/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData

open class TableModelController<TableModelType:  Model<UITableView>>: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet public weak var tableView: UITableView!

    public let bag = DisposeBag()
    public var context: NSManagedObjectContext!
    public var manuallyManageDataUpdate: Bool = false

    public lazy var model: TableModelType = { return createModel() }()

    open func createModel() -> TableModelType {
        return TableModelType(with: context)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        model.sectionsObservable.subscribe(onNext: { [unowned self] (_) in
            if self.manuallyManageDataUpdate {
                return
            }
            self.tableView.reloadData()
        }).disposed(by: bag)
    }
    
    // MARK: - TableView
    public func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(in: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = model.row(at: indexPath) else {
            fatalError("TableModelController no cell at \(indexPath)")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.performTap(at: indexPath, sender: tableView, in: self)
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.section(at: section)?.headerTitle
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.section(at: section)?.footerTitle
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return model.canEdit(at: indexPath)
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            manuallyManageDataUpdate = true
            model.delete(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            manuallyManageDataUpdate = false
        }
    }
}
