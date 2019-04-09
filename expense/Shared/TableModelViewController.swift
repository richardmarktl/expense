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
import SwiftRichString

class TableModelController<Model: TableModel>: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let bag = DisposeBag()
    var context: NSManagedObjectContext!
    var lastSelectedItem: ConfigurableRow?
    var manuallyManageDataUpdate: Bool = false
    
    lazy var model: Model = { return createModel() }()
    
    public func createModel() -> Model {
        return Model(with: context)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView
        tableView.register(R.nib.settingsCell)
        tableView.register(R.nib.userCell)
        tableView.register(UINib(resource: R.nib.tableFooterView), forHeaderFooterViewReuseIdentifier:R.nib.tableFooterView.name)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = model.sections[indexPath.section].rows[indexPath.row]
        item.performTap(indexPath: indexPath, tableView: tableView, in: self, model: model)
        
        if let lastItem = lastSelectedItem, item.identifier != lastItem.identifier {
            lastItem.rewindAction(tableView: tableView, in: self, model: model)
            lastSelectedItem = nil
        }
        
        lastSelectedItem = item
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].headerTitle
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard model.sections[section].footerTitle != nil else {
            return 0
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let identifier = R.nib.tableFooterView.name
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? TableFooterView
        footer?.footerLabel?.attributedText = model.sections[section].footerTitle?.set(style: StyleGroup.headerFooterStyleGroup())
        return footer
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.textLabel?.font = UIFont.headerFooterFont()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return model.canEdit(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            manuallyManageDataUpdate = true
            model.delete(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            manuallyManageDataUpdate = false
        }
    }
}
