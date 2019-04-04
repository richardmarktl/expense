//
//  JobViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 14/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import Horreum
import MessageUI
import SwiftReorder


class JobViewController: UIViewController, Sendable, AutoScroller {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: ActionButton!
    @IBOutlet weak var saveButton: ActionButton!
    @IBOutlet weak var balanceBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var balanceView: BalanceView!
    
    private let bag = DisposeBag()
    
    private var job: Job!
    private var jobModel: JobModel!
    
    private var childContext: NSManagedObjectContext = {
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = Horreum.instance!.mainContext
        return childContext
    }()
    
    private var toolTipView: EasyTipView?
    private var lastSelectedItem: ConfigurableRow?
    
    var scrollViewDefaultInsets: UIEdgeInsets = .zero
    var scrollView: UIScrollView!
    var additionalHeight: CGFloat = 0
    
    class func createInvoice() -> UIViewController {
        guard let nCtr = R.storyboard.jobs.jobNavigationController(), let ctr = nCtr.childViewControllers.first as? JobViewController else {
            fatalError()
        }
        
        ctr.job = Invoice.create(in: ctr.childContext)
        return nCtr
    }
    
    class func createOffer() -> UIViewController {
        guard let nCtr = R.storyboard.jobs.jobNavigationController(), let ctr = nCtr.childViewControllers.first as? JobViewController else {
            fatalError()
        }
        
        ctr.job = Offer.create(in: ctr.childContext)
        return nCtr
    }
    
    class func create(for job: Job) -> UIViewController {
        guard let nCtr = R.storyboard.jobs.jobNavigationController(), let ctr = nCtr.childViewControllers.first as? JobViewController else {
            fatalError()
        }
        
        ctr.job = ctr.childContext.object(with: job.objectID) as? Job
        return nCtr
    }
    
    class func createInvoice(forClient clientObjectId: NSManagedObjectID) -> UIViewController {
        return create(forClient: clientObjectId, createObject: Invoice.create)
    }
    
    class func createOffer(forClient clientObjectId: NSManagedObjectID) -> UIViewController {
        return create(forClient: clientObjectId, createObject: Offer.create)
    }
    
    class func create(forClient clientObjectId: NSManagedObjectID, createObject: (NSManagedObjectContext) -> Job) -> UIViewController {
        guard let nCtr = R.storyboard.jobs.jobNavigationController(), let ctr = nCtr.childViewControllers.first as? JobViewController else {
            fatalError()
        }
        
        let job = createObject(ctr.childContext)
        
        let client = ctr.childContext.object(with: clientObjectId) as? Client
        job.client = client
        job.update(from: client)
        
        ctr.job = job
        
        return nCtr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSampleHeaderPrompt()
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = FiraSans.regular.font(14)
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor.main
        EasyTipView.globalPreferences = preferences
        
        // the insets are added to allow a footer view.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        // reorder support
        tableView.reorder.delegate = self
        
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 48, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 58, right: 0)
        tableView.register(R.nib.languageCell)
        tableView.register(R.nib.currencyCell)
        tableView.register(R.nib.switchCell)
        tableView.register(R.nib.dateCell)
        tableView.register(R.nib.jobDetailCell)
        
        scrollView = tableView // needed for the autoscroller implementation

        jobModel = JobModel(with: job, in: childContext)
        jobModel.titleObservable.subscribe(onNext: { [unowned self](title) in
            if title == nil {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
                activityIndicator.startAnimating()
                self.navigationItem.titleView = activityIndicator
            } else {
                self.navigationItem.titleView = nil
                self.navigationItem.title = title
            }
        }).disposed(by: bag)
        
        jobModel.balanceObservable.subscribe(onNext: { [unowned self](balance) in
            self.balanceView.update(with: balance)
        }).disposed(by: bag)
        
        setupPaymentRegister()
        setupSignatureUpsell()
 
        deleteButton.isHidden = jobModel.isDeleteButtonHidden
        deleteButton.tapObservable.subscribe(onNext: { [unowned self] () in
            let message = R.string.localizable.deletionDetected()
            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.cancel, handler: nil)
            let save = UIAlertAction(title: R.string.localizable.delete(), style: UIAlertActionStyle.default, handler: { [weak self](_) in
                self?.jobModel.delete()
                self?.dismiss(animated: true)
            })

            alert.addAction(cancel)
            alert.addAction(save)
            self.present(alert, animated: true)
        }).disposed(by: bag)
        
        
        if let rightBarButtonItem = navigationItem.rightBarButtonItem {
            
            rightBarButtonItem.setTitleTextAttributes([
                NSAttributedStringKey.font: FiraSans.medium.font(16),
                NSAttributedStringKey.foregroundColor: UIColor.white], for: [])
            
            let rightSaveObs = rightBarButtonItem.rx.tap.asObservable().do(onNext: { (_) in
                Analytics.saveTopRight.logEvent()
            })
            
            let saveButtonObs = saveButton.tapObservable.do(onNext: { (_) in
                Analytics.saveNormal.logEvent()
            })
            
            Observable.of(rightSaveObs, saveButtonObs)
                .merge()
                .subscribe(onNext: { (_) in
                    // show an reset dialog in the case the use has send it already
                    _ = self.shouldReset(showDialog: self.jobModel.job.willResetSignature).take(1).filterTrue().subscribe(onNext: { (_) in
                        
                        self.jobModel.save()
                        if self.jobModel.shouldTriggerAppRateDialogEventOnDismiss {
                            self.shouldShowAppRateEvent()
                        }
                        self.dismiss(animated: true)
                    })
                }).disposed(by: bag)
        }
        
        navigationItem.leftBarButtonItem?.rx.tap.asObservable().flatMap({ [unowned self] (_) -> Observable<Void> in
            Analytics.cancel.logEvent(["hasWarning": self.jobModel.shouldShowCancelWarning.asNSNumber])
            if self.jobModel.shouldShowCancelWarning {
                return self.cancelAlert(for: self.jobModel)
            } else {
                return Observable.just(())
            }
        }).subscribe(onNext: { [unowned self] (_) in
            self.dismiss(animated: true)
        }).disposed(by: bag)
        
        if FirstUserJourneyState.load() == .addClient && UserDefaults.firstTimeUpsellState == .none {
            UserDefaults.storeFirstTimeUpsellState(state: .shouldShow)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollViewDefaultInsets = scrollView.contentInset  // add this in the case the keyboard is already visible
        registerForKeyboardEvents(rx.viewWillDisappear.mapToVoid())
    
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let nextJourneyState = jobModel.nextFirstUserJourneyState()
        if nextJourneyState.isInProgress {
            toolTipView = EasyTipView(text: nextJourneyState.toolTip)
            let view: UIView
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)), nextJourneyState == .addClient {
                view = cell
            } else if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)), nextJourneyState == .addItem {
                view = cell
            } else {
                view = balanceView
            }
            
            _ = tableView.rxDidScroll.take(1).subscribe(onNext: { [weak self] (_) in
                self?.toolTipView?.dismiss()
            })
            
            toolTipView?.show(forView: view)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toolTipView?.dismiss()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let footerView = tableView.tableFooterView {
            
            let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            let footerFrame = footerView.frame
            
            if height != footerFrame.height {
                footerView.frame = CGRect(x: 0, y: 0, width: footerFrame.width, height: height)
                tableView.tableFooterView = footerView
            }
        }
    }
    
    /// This method observes the payment provider observable and will if necessary call
    /// the controller to setup a payment provider.
    private func setupPaymentRegister() {
        guard let invoice = job as? Invoice else {
            return
        }
        jobModel.paymentSection?.stripeObservable.subscribe(onNext: { [unowned self] (_) in
            let ctr = StripeSetupViewController(nibName: nil, bundle: nil)
            ctr.cancelObservable.subscribe(onNext: { [unowned self] (_) in
                invoice.isStripeActivated = false
                self.jobModel.paymentSection?.stripe.reset(false)
            }).disposed(by: self.bag)
            self.showUpsellController(or: ctr, reset: self.jobModel.paymentSection?.stripe)
        }).disposed(by: bag)
        
        jobModel.paymentSection?.paypalObservable.subscribe(onNext: { [unowned self] (_) in
            let ctr = PayPalSetupViewController.controller()
            ctr.cancelObservable.subscribe(onNext: { [unowned self] (_) in
                invoice.isPayPalActivated = false
                self.jobModel.paymentSection?.paypal.reset(false)
            }).disposed(by: self.bag)
            self.showUpsellController(or: ctr, reset: self.jobModel.paymentSection?.paypal)
        }).disposed(by: bag)
    }
    
    
    /// This method observers the signature provider and helps to handle the buttons.
    private func setupSignatureUpsell() {
        jobModel.signatureSection.customerSignatureObservable.subscribe(onNext: { [unowned self] (_) in
            if CurrentAccountState.isPro == false {
                self.jobModel.signatureSection.customerSignature.reset(false)
                UpsellTrialExpiredController.present(in: self)
            }
        }).disposed(by: bag)
        
        jobModel.signatureSection.userSignatureObservable.subscribe(onNext: { [unowned self] (signature) in
            if signature && SignatureViewController.hasSignatureImage() == false {
                guard let ctr: SignatureViewController = R.storyboard.signature.instantiateInitialViewController() else {
                    return
                }
                
                // did cancel remove
                ctr.cancelObservable.subscribe(onNext: { [unowned self] (_) in
                    self.jobModel.signatureSection.removeSignature()
                    self.jobModel.signatureSection.userSignature.reset(false)
                }).disposed(by: self.bag)
                ctr.signatureObservable.subscribe(onNext: { [unowned self] (_) in
                    self.jobModel.signatureSection.addSignature()
                    
                }).disposed(by: self.bag)
                self.showUpsellController(or: ctr, reset: self.jobModel.signatureSection.userSignature)
            }
        }).disposed(by: bag)
    }
    
    /// This method will show the payment controller if the user has a pro version otherwise the upsell controller.
    ///
    /// - Parameter paymentController: an UIViewController object.
    private func showUpsellController(or paymentController: UIViewController, reset item: BoolItem?) {
        if CurrentAccountState.isPro {
            navigationController?.pushViewController(paymentController, animated: true)
        } else {
            item?.reset(false)
            UpsellTrialExpiredController.present(in: self)
        }
    }

    private func setSampleHeaderPrompt() {
        if job.remoteId == DefaultData.TestRemoteID {
            if job is Invoice {
                navigationItem.prompt = R.string.localizable.sampleInvoice()
            } else {
                navigationItem.prompt = R.string.localizable.sampleOrder()
            }
        }
    }
    
    private func shouldShowAppRateEvent() {
        
        if !CurrentAccountState.hasPurchasedPro {
            Analytics.ratingDoNothingSinceUserDidNotPurchaseApp.logEvent()
            return
        }
        
        Analytics.ratingIncreaseSignificantUse.logEvent()
        RatingService.instance.increaseEventNumber()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75) {
            if RatingService.instance.shouldShowRatingDialog() {
                Analytics.ratingConditionsMetTryingToShow.logEvent()
                RatingDisplayable.showRatingDialog()
            } else {
                Analytics.ratingConditionsNotMetYet.logEvent()
            }
        }
    }
    
    private func cancelAlert(for model: JobModel) -> Observable<Void> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            
            let alert = UIAlertController(title: nil, message: R.string.localizable.changesDetected(), preferredStyle: UIAlertControllerStyle.alert)
            
            let cancel = UIAlertAction(title: R.string.localizable.discard(), style: UIAlertActionStyle.cancel, handler: { (_) in
                observer.onNext(())
                observer.onCompleted()
                Analytics.discard.logEvent()
            })
            
            let save = UIAlertAction(title: R.string.localizable.save(), style: UIAlertActionStyle.default, handler: { [weak self] (_) in
                model.save()
                if model.shouldTriggerAppRateDialogEventOnDismiss {
                    self?.shouldShowAppRateEvent()
                }
                observer.onNext(())
                observer.onCompleted()
                Analytics.saveFromAlert.logEvent()
            })
            
            alert.addAction(cancel)
            alert.addAction(save)
            
            self?.present(alert, animated: true)
            
            return Disposables.create()
        })
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        Locale.current.currencyCode.map(Currency.create).map(CurrencyLoader.update)
    }
}

extension JobViewController: UITableViewDataSource, UITableViewDelegate, TableViewReorderDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return jobModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobModel.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let rowItem = jobModel.sections[indexPath.section].rows[indexPath.row]
        let identifier = rowItem.reuseIdentifier
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        rowItem.configure(cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let item = jobModel.sections[indexPath.section].rows[indexPath.row]
        if item.canPerformTap(indexPath: indexPath, tableView: tableView, in: self, model: jobModel) {
            return indexPath
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = jobModel.sections[indexPath.section].rows[indexPath.row]
        item.performTap(indexPath: indexPath, tableView: tableView, in: self, model: jobModel)
        
        if let lastItem = lastSelectedItem, item.identifier != lastItem.identifier {
            lastItem.rewindAction(tableView: tableView, in: self, model: jobModel)
            lastSelectedItem = nil
        }
        
        lastSelectedItem = item
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return jobModel.sections[section].headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return jobModel.sections[section].footerTitle
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 5 : UITableViewAutomaticDimension //tableView.sectionFooterHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 5 : UITableViewAutomaticDimension //tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        let section: TableSection = jobModel.sections[indexPath.section]
        return section.canBeReordered(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForReorderFromRowAt sourceIndexPath: IndexPath, to proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let section: TableSection = jobModel.sections[sourceIndexPath.section]
        return section.targetIndexPathForReorderFromRow(at: sourceIndexPath, to: proposedDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    
    func tableViewDidBeginReordering(_ tableView: UITableView, at indexPath: IndexPath) {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        let section: TableSection = jobModel.sections[initialSourceIndexPath.section]
        section.reorderRow(at: initialSourceIndexPath, to: finalDestinationIndexPath)
        
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        Analytics.changeOrder.logEvent()
    }
}
