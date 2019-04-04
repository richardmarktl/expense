//
//  JobsContainerViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 10/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

class JobsContainerViewController: UIViewController, Containable {
    
    fileprivate let bag = DisposeBag()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var addInVoiceButton: HoverButton!
    @IBOutlet weak var invoiceBotButton: HoverButton!
    
    @IBOutlet weak var addButtonRightAlignment: NSLayoutConstraint!
    
    fileprivate let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [R.string.localizable.offered(), R.string.localizable.invoiced(), R.string.localizable.paid()])
        segmentedControl.selectedSegmentIndex = 1
        return segmentedControl
    }()
    
    fileprivate lazy var offersController: OfferedJobsViewController = {
        return OfferedJobsViewController()
    }()
    
    fileprivate lazy var invoicedController: InvoicedJobsViewController = {
        return InvoicedJobsViewController()
    }()
    
    fileprivate lazy var paidController: PaidJobsViewController = {
        return PaidJobsViewController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupSearch()

        //handle tap stuff
        addInVoiceButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            if !CurrentAccountState.isProExpired {
                self.showAddJobController()
            } else {
                UpsellTrialExpiredController.present(in: self)
            }
        }).disposed(by: bag)

        invoiceBotButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            if !CurrentAccountState.isProExpired {
                self.showVoiceJobController()
            } else {
                UpsellTrialExpiredController.present(in: self)
            }
        }).disposed(by: bag)
        
        segmentedControl.rx.value.asObservable().startWith(0).distinctUntilChanged().subscribe(onNext: { [unowned self] (idx) in
            self.handleSegmentedControlChange(to: idx)
        }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.job.logEvent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if searchController.isActive {
            searchController.isActive = false
            UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navCtr = segue.destination as? UINavigationController,
           let invCtr = navCtr.childViewControllers.first as? InvoiceVoiceViewController,
           let source = sender as? JobsViewController {
            invCtr.source = source
            invCtr.sourceType = type(of: source) == OfferedJobsViewController.self ? .offer : .invoice
            // analize the usage of the voice controller
            switch invCtr.sourceType {
            case .offer:
                Analytics.jobVoiceAddOffer.logEvent()
            case .invoice:
                Analytics.jobvoiceAddInvoice.logEvent()
            }
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.titleView = segmentedControl
        //this doesn't work if we set it in the storyboard, no idea why
        navigationController?.navigationBar.prefersLargeTitles = true
        title = R.string.localizable.jobs()
    }
    
    fileprivate func setupSearch() {
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }

    /// Handles the change to a different segment
    ///
    /// - Parameter index: the segment we changed to
    fileprivate func handleSegmentedControlChange(to index: Int) {
        switch index {
        case 0:
            addAndSetDelegate(asChildViewController: offersController)
            showActionButtonsIfNeeded()
            Analytics.jobOffer.logEvent()
        case 1:
            addAndSetDelegate(asChildViewController: invoicedController)
            showActionButtonsIfNeeded()
            Analytics.jobInvoice.logEvent()
        case 2:
            addAndSetDelegate(asChildViewController: paidController)
            hideActionButtonsIfNeeded()
            Analytics.jobPaid.logEvent()
        default:
            return
        }
    }
    
    fileprivate func addAndSetDelegate(asChildViewController viewController: UIViewController & UISearchResultsUpdating & UISearchControllerDelegate) {
        searchController.searchResultsUpdater = viewController
        searchController.delegate = viewController
        add(asChildViewController: viewController)
    }
    
    fileprivate func showAddJobController() {
        let ctr: UIViewController
        if segmentedControl.selectedSegmentIndex == 0 {
            ctr = JobViewController.createOffer()
            Analytics.jobAddOffer.logEvent()
        } else {
            ctr = JobViewController.createInvoice()
            Analytics.jobAddInvoice.logEvent()
        }
        present(ctr, animated: true)
    }
    
    fileprivate func limitCheckerType() -> LimitChecker.LimitType {
        return self.segmentedControl.selectedSegmentIndex == 0 ? LimitChecker.LimitType.offer : LimitChecker.LimitType.invoice
    }
    
    fileprivate func showVoiceJobController() {
        self.performSegue(withIdentifier: R.segue.jobsContainerViewController.show_bot, sender: self.childViewControllers.first!)
    }
    
    fileprivate func showActionButtonsIfNeeded() {
        
        if addButtonRightAlignment.constant == 16 {
            return
        }
        
        view.layoutIfNeeded()
        addButtonRightAlignment.constant = 16
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.50, initialSpringVelocity: 1.0, options: [], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func showUpsellMessage() {
        let title = segmentedControl.selectedSegmentIndex == 0 ?
            R.string.localizable.offers() : R.string.localizable.invoices()
        let message = R.string.localizable.limitReached(title)
        showUpsellAlert(message: message)
    }
    
    fileprivate func hideActionButtonsIfNeeded() {
        
        if addButtonRightAlignment.constant != 16 {
            return
        }
        
        view.layoutIfNeeded()
        
        addButtonRightAlignment.constant = -addInVoiceButton.frame.width - 16
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: {
            self.view.layoutIfNeeded()
        })
    }
}
