//
//  ClientPickerViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 16/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum
import RxSwift
import RxCocoa
import CoreData

class ClientPickerViewController: UITableViewController {
    
    fileprivate let searchSubject: PublishSubject<String> = PublishSubject()
    private let bag = DisposeBag()
    private let searchController: UISearchController = UISearchController(searchResultsController: nil)
    private var model: ClientPickerModel!
    
    var context: NSManagedObjectContext!
    var completionBlock: ((Client) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] in
            Analytics.cancel.logEvent()
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        
        model = ClientPickerModel(searchObservable: searchSubject.asObservable().startWith(""), context: context)
        model.sectionsObservable.subscribe(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: bag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.textLabel?.font = UIFont.headerFooterFont()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            searchController.dismiss(animated: false, completion: nil)
        }
        let item = model.sections[indexPath.section].rows[indexPath.row]
        item.performTap(indexPath: indexPath, tableView: tableView, in: self, model: model)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].headerTitle
    }
}

// MARK: - UISearchResultsUpdating
extension ClientPickerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchSubject.onNext(searchController.searchBar.text ?? "")
    }
}
