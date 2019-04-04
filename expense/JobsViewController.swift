//
//  JobListViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 10/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import Horreum
import SwiftRichString

// MARK: - Specific Impl
class OfferedJobsViewController: JobsViewController {
    
    init() {
        super.init(nibName: "ReuseableJobController", bundle: nil)
        emptyMessage = R.string.localizable.noOffersMessage()
        emptyTitle = R.string.localizable.noOffersTitle()
        model = JobItemModel(searchObservable: searchObservable, loadObservable: JobItemObservables.offerObservable(in: Horreum.instance!.mainContext))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class InvoicedJobsViewController: JobsViewController {
    
    init() {
        super.init(nibName: "ReuseableJobController", bundle: nil)
        emptyMessage = R.string.localizable.noInvoicedMessage()
        emptyTitle = R.string.localizable.noInvoicedTitle()
        model = JobItemModel(searchObservable: searchObservable, loadObservable: JobItemObservables.invoiceObservable(in: Horreum.instance!.mainContext))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class PaidJobsViewController: JobsViewController {
    
    init() {
        super.init(nibName: "ReuseableJobController", bundle: nil)
        emptyMessage = R.string.localizable.noPaidInvoicedMessage()
        emptyTitle = R.string.localizable.noPaidInvoicedTitle()
        model = JobItemModel(searchObservable: searchObservable, loadObservable: JobItemObservables.paidInvoiceObservable(in: Horreum.instance!.mainContext))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class UnpaidInvoicesController: JobsViewController {
    init() {
        super.init(nibName: "ReuseableJobController", bundle: nil)
        hidesBottomBarWhenPushed = true
        model = JobItemModel(searchObservable: searchObservable, loadObservable: JobItemObservables.unpaidInvoiceObservable(in: Horreum.instance!.mainContext))
        title = R.string.localizable.outstanding()
        emptyMessage = R.string.localizable.noOutstandingMessage()
        emptyTitle = R.string.localizable.noOutstandingTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class OverdueInvoicesController: JobsViewController {
    init() {
        super.init(nibName: "ReuseableJobController", bundle: nil)
        hidesBottomBarWhenPushed = true
        model = JobItemModel(searchObservable: searchObservable, loadObservable: JobItemObservables.overdueInvoiceObservable(in: Horreum.instance!.mainContext))
        title = R.string.localizable.overdueInvoices()
        emptyMessage = R.string.localizable.noOverdueInvoucesMessage()
        emptyTitle = R.string.localizable.noOverdueInvoices()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class OverdueTomorrowInvoicesController: JobsViewController {
    init() {
        super.init(nibName: "ReuseableJobController", bundle: nil)
        hidesBottomBarWhenPushed = true
        model = JobItemModel(searchObservable: searchObservable, loadObservable: JobItemObservables.overdueTomorrowInvoiceObservable(in: Horreum.instance!.mainContext))
        title = R.string.localizable.overdueTomorrowInvoices().replacingOccurrences(of: "\n", with: " ")
        emptyMessage = R.string.localizable.noOverdueInvoucesMessage()
        emptyTitle = R.string.localizable.noOverdueInvoices()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class UnsentInvoicesController: JobsViewController {
    init() {
        super.init(nibName: "ReuseableJobController", bundle: nil)
        hidesBottomBarWhenPushed = true
        model = JobItemModel(searchObservable: searchObservable, loadObservable: JobItemObservables.unsentInvoiceObservable(in: Horreum.instance!.mainContext))
        title = R.string.localizable.unsent()
        emptyMessage = R.string.localizable.noUnsentMessage()
        emptyTitle = R.string.localizable.noUnsentTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class UnseenInvoicesController: JobsViewController {
    init() {
        super.init(nibName: "ReuseableJobController", bundle: nil)
        hidesBottomBarWhenPushed = true
        model = JobItemModel(searchObservable: searchObservable, loadObservable: JobItemObservables.unopenedInvoiceObservable(in: Horreum.instance!.mainContext))
        title = R.string.localizable.unseen()
        emptyMessage = R.string.localizable.noUnseenMessage()
        emptyTitle = R.string.localizable.noUnseenTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - General Impl
class JobsViewController: UIViewController, EmptyViewable {
    
    @IBOutlet weak var tableView: UITableView!
    
    var emptyMessage: String = ""
    var emptyTitle: String = ""
    var job: Job?
    var isSearching: Bool = false
    var emptyViewInsertBelowView: UIView? = nil
    
    fileprivate let bag = DisposeBag()
    fileprivate var trialBannerView: TrialBannerView? = nil
    
    /// Search Objects
    fileprivate let searchSubject = PublishSubject<String>()
    fileprivate var searchObservable: Observable<String> {
        return searchSubject.asObservable().debounce(0.5, scheduler: MainScheduler.instance).startWith("")
    }
    
    fileprivate var model: JobItemModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(R.nib.reusableJobCell)
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        model.jobItemObservable.subscribe(onNext: { [unowned self] (items) in
            
            if !self.isSearching {
                let show = items.count == 0
                self.showEmptyViewController(show)
            }
            
            self.tableView.reloadData()
            
        }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showBannerViewIfNeeded()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            highlightJobIfNeeded()
        }
    }
    
    fileprivate func showBannerViewIfNeeded() {
        let state = CurrentAccountState.value
        if ((state == .freeTrail || state == .trialExpired || state == .promo) && !isSearching) {
            if (trialBannerView == nil) {
                addBannerView()
            }
            trialBannerView?.updateWithState(state: state)
        } else {
            trialBannerView?.removeFromSuperview()
            trialBannerView = nil
            tableView.contentInset = .zero
        }
    }
    
    fileprivate func addBannerView() {
        let trialBannerView = TrialBannerView()
        view.addSubview(trialBannerView)
        
        trialBannerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        trialBannerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        trialBannerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        trialBannerView.setNeedsUpdateConstraints()
        trialBannerView.updateConstraintsIfNeeded()
        trialBannerView.setNeedsLayout()
        trialBannerView.layoutIfNeeded()
        
        trialBannerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        trialBannerView.tapObservable.subscribe(onNext: { (_) in
            Analytics.upsellTrialBannerTapped.logEvent()
            if !CurrentAccountState.isProExpired{
                Upsell2Controller.present(in: self)
            } else {
                UpsellTrialExpiredController.present(in: self)
            }
        }).disposed(by: bag)
        
        self.trialBannerView = trialBannerView
        tableView.contentInset = UIEdgeInsetsMake(trialBannerView.frame.height - 4, 0, 0, 0)
    }
    
    fileprivate func highlightJobIfNeeded() {
        if let job = job, let row = model.indexOf(job: job) {
            let indexPath = IndexPath(row: row, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
            // move the deselection into the next drawing cycle.
            DispatchQueue.main.async {
                if self.tableView.numberOfRows(inSection: 0) > indexPath.row {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        }
        job = nil // set it back, to prevent an accidentally deselection.
    }
}

// MARK: - Search implementation
extension JobsViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchTerm = searchController.searchBar.text ?? ""
        searchSubject.onNext(searchTerm)
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        isSearching = true
        showBannerViewIfNeeded()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        isSearching = false
        showBannerViewIfNeeded()
    }
}

// MARK: - TableView implementation
extension JobsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.jobItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.jobCell, for: indexPath)!
        cell.item = model.jobItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let logCtr = String(describing: type(of: self)) as NSString
        Analytics.showJobDetails.logEvent(["ctr": logCtr])
        
        let job = model.jobItems[indexPath.row].item
        let ctr = JobViewController.create(for: job)
        present(ctr, animated: true)
        self.job = job  // set the job to be able to deselect the entry animated.
    }
}
