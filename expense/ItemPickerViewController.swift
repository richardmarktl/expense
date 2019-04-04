//
//  ItemPickerViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum
import CoreData
import RxSwift
import RxCocoa

class ItemPickerViewController: UITableViewController {
    
    fileprivate let searchSubject: PublishSubject<String> = PublishSubject()
    fileprivate var isSearching: Bool = false
    
    private let bag = DisposeBag()
    private var model: ItemPickerModel!
    
    var completionBlock: ((Order) -> Void)?
    var context: NSManagedObjectContext!
    var job: Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(R.nib.itemCell)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] in
            Analytics.cancel.logEvent()
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        
        model = ItemPickerModel(searchObservable: searchSubject.asObservable().startWith(""), for: job, context: context)
        model.sectionsObservable.subscribe(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: bag)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        navigationItem.searchController?.isActive = false
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        
        let item = model.sections[indexPath.section].rows[indexPath.row]
        item.performTap(indexPath: indexPath, tableView: tableView, in: self, model: model)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].headerTitle
    }
}

// MARK: - UISearchResultsUpdating
extension ItemPickerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchSubject.onNext(searchController.searchBar.text ?? "")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        isSearching = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        isSearching = false
    }
}
