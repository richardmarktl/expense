//
//  SearchableTableModelController.swift
//  InVoice
//
//  Created by Georg Kitz on 18/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData

class SearchableTableModelController<ItemType, Model: SearchableTableModel<ItemType>>: TableModelController<Model>, UISearchResultsUpdating, UISearchControllerDelegate, EmptyViewable {
    
    var emptyTitle: String = ""
    var emptyMessage: String = ""
    var emptyViewInsertBelowView: UIView?
    
    private(set) var isSearching: Bool = false
    
    fileprivate let searchSubject: PublishSubject<String> = PublishSubject()
    var searchObservable: Observable<String> {
        return searchSubject.asObservable().startWith("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        model.sectionsObservable.skip(1).subscribe(onNext: { [unowned self] (sections) in
            if !self.isSearching {
                var show = true
                for section in sections where section.rows.count > 0 {
                    show = false
                    break
                }
                self.showEmptyViewController(show)
            }
        }).disposed(by: bag)
        
        navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        navigationItem.searchController?.isActive = false
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - SearchResults
    func updateSearchResults(for searchController: UISearchController) {
        searchSubject.onNext(searchController.searchBar.text?.lowercased() ?? "")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        isSearching = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        isSearching = false
    }
}
