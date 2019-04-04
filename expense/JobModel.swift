//
//  JobModel.swift
//  InVoice
//
//  Created by Georg Kitz on 14/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import SwiftMoment
import CoreData
import Intents
import Crashlytics

/*
 - row type (
    - textfield
        - title, input, *storage item* (text)
    - date
        - title, input, *storage item* (text)
    - due date
        - title, input, *storage item* (text)
    - add actions
        - title, icon
    - client
        - title, subtitle, delete icon, *storage item* (client)
    - item
        - title, subtitle, price, *storage item* (order)
    - attachment
        - image, title, delete button, *storate item* (storage)
    - textview
        - title, input, *storate item* (text)
    - actions
        - title, action
 )
 */

// MARK: - Row stuff

class JobModel: TableModel {
    
    let job: Job
    let renderer: PerformanceInvoiceGenerator
    lazy var jobNumberModel: JobNumberModel = {
        let request = job is Invoice ? InvoiceRequest.next() : OfferRequest.next()
        return JobNumberModel(loadJobNumberObservable: request, reachabilityObservable: reachabilityManager.reachable)
    }()
    
    let jobSection: JobDetailSection
    let dateSection: DateSection
    let clientSection: ClientSection
    let itemSection: AddItemSection
    let extraSection: ExtraSection
    let billingSection: BillingSection  // enter payments by hand
    let actionSection: ActionSection
    let paymentSection: PaymentSection?  // invoice only, payments paid through payment providers (stripe, paypal ...)
    let recipientSection: RecipientSection
    let signatureSection: SignatureSection
    let balanceObservable: Observable<Balance>
    
    let isDeleteButtonHidden: Bool
    let shouldTriggerAppRateDialogEventOnDismiss: Bool
    
    private let jobNumberVariable: Variable<JobNumber?> = Variable(nil)
    var jobNumberValid: Observable<Bool> {
        return jobNumberVariable.asObservable().map({ (value) -> Bool in
            return value != nil && value!.valid
        })
    }
    var titleObservable: Observable<String?> {
        return jobNumberVariable.asObservable().map({ (value) -> String? in
            return value?.value
        })
    }
    
    var isLoadingTitle: Observable<Bool> {
        return jobNumberVariable.asObservable().map({ (value) -> Bool in
            return value == nil
        })
    }
    
    var shouldShowCancelWarning: Bool {
        let all = context.updatedObjects
        let shouldShow = all.reduce(false) { (current, object) -> Bool in
            let changes = object.changedValues().filter({ (args) -> Bool in
                let (key, _) = args
                logger.verbose("UPDATED: \(key)")
                 return key != "updatedTimestamp" && key != "localUpdateTimestamp"
            })
            return current || changes.count > 0
        }
        logger.verbose("shouldShowCancelWarning show: \(shouldShow)")
        return shouldShow
    }
    
    init(with job: Job, in context: NSManagedObjectContext) {
        
        LanguageLoader.updateCurrentLanguageBundle(to: job.language)
        
        isDeleteButtonHidden = job.isInserted
        shouldTriggerAppRateDialogEventOnDismiss = job.isInserted && !job.hasRemoteId
        self.job = job
        
        jobSection = JobDetailSection(job: job)
        dateSection = DateSection(job: job)
        clientSection = ClientSection(job: job)
        itemSection = AddItemSection(job: job)
        extraSection = ExtraSection(job: job, in: context)
        billingSection = BillingSection(job: job, in: context)
        actionSection = ActionSection(job: job)
        recipientSection = RecipientSection(job: job, in: context)

        if let invoice = job as? Invoice {
            paymentSection = PaymentSection(job: invoice, in: context)
        } else {
            paymentSection = nil
        }
        signatureSection = SignatureSection(job: job, in: context)
        
        balanceObservable = BalanceModel.balanceObservable(for: job, in: context).share()
        
        let design = JobDesign.allObjects(matchingPredicate: NSPredicate.undeletedItem(), context: context).first!
        renderer = PerformanceInvoiceGenerator(job: job, template: design.template!, color: design.color!, observeChangesIn: context)!
        
        super.init(with: context)
        sections = [
            jobSection,
            dateSection,
            clientSection,
            itemSection,
            extraSection,
            billingSection,
            signatureSection,
            recipientSection,
            actionSection
        ]
        
        // in the case there is payment section insert it after the billing section.
        if let payment = paymentSection {
            sections.insert(payment, at: sections.firstIndex(where: { $0 === billingSection }) ?? 6)
        }
        
        // job number handling
        let numberLoadingObservable: Observable<JobNumber>
        if job.number == nil || job.number! == JobNumber.invalidJobNumber.value {
            numberLoadingObservable = jobNumberModel.jobNumberObservable.do(onNext: { [weak self](number) in
                self?.job.number = number.value
            })
        } else {
            numberLoadingObservable = Observable.just(JobNumber(valid: true, value: job.number!))
        }
        numberLoadingObservable.subscribe(onNext: { [weak self](value) in
            self?.jobNumberVariable.value = value
        }).disposed(by: bag)
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError()
    }
    
    fileprivate func logSaveEventForJob() {
        let isPro = StoreService.instance.hasValidReceipt
        let additionalInformation = ["pro": NSNumber(value: isPro)]
        if job is Invoice {
            if job.isInserted {
                Analytics.saveNewInvoice.logEvent(additionalInformation)
            } else {
                Analytics.saveModifiedInvoice.logEvent(additionalInformation)
            }
        } else {
            if job.isInserted {
                Analytics.saveNewOffer.logEvent(additionalInformation)
            } else {
                Analytics.saveModifiedOffer.logEvent(additionalInformation)
            }
        }
    }
    
    /// Helper Method, you might ask why, well we want the invoice to have all updated data when
    /// - we press save in the controller
    /// - the user opens the send email/share action. Both those actions should reflect the correct data is used
    func updateJobForSaving() {
        job.updatedTimestamp = Date()
        job.localUpdateTimestamp = Date()
        
        itemSection.orders.forEach { (order) in
            order.item = job
        }
        
        extraSection.attachments.forEach { (attachment) in
            attachment.job = job
        }
        
        job.paymentDetails = extraSection.paymentDetail.value.value.databaseValue
        job.note = extraSection.note.value.value.databaseValue
        
        // Check the total balance, if it changes set it otherwise not, to prevent the change trigger
        // in the managed object.
        let balance = BalanceModel.balance(for: job)
        let total =  balance.total.asRounded()
        if total != job.total {
            job.total = total
        }
        
        if let invoice = job as? Invoice, invoice.total != NSDecimalNumber.zero {
            if invoice.paidTimestamp == nil && balance.balanceValue <= NSDecimalNumber.zero {
                invoice.paidTimestamp = Date()
            } else if invoice.paidTimestamp != nil && balance.balanceValue > NSDecimalNumber.zero {
                invoice.paidTimestamp = nil
            }
        }
    }
    
    /// Idealy this is called once the job was saved, to actually upload all the changes :D
    /// - when the user presses save
    /// - the user presses the share button
    /// - the user sends an email (currently that's not happenung there, we want to change that in the future)
    func uploadJob(job: Job, in context: NSManagedObjectContext) {
        //data to upload
        let saveContext = context
        let changedOrders = job.changedOrders
        let changedAttachments = job.changedAttachements
        let changedPayments = job.changedPayments
        
        if job.remoteId != DefaultData.TestRemoteID { // do not upload test data
            _ = ClientUploader.upload(for: job)
                .flatMap({ (job) -> Observable<Job> in
                    return JobUploader.upload(job, changedOrders: changedOrders, changedAttachments: changedAttachments, changedPayments: changedPayments)
                })
                .take(1)  // the upload of the client the upload of the job
                .subscribe(onNext: { _ in
                    try? saveContext.save()
                })
        }
    }
    
    func save() {
        logSaveEventForJob()
        
        updateJobForSaving()
        uploadJob(job: job, in: context)
        donateJob()
        
        try? context.save()
    }

    func delete() {
        Analytics.delete.logEvent()
        job.deletedTimestamp = Date()
        try? context.save()
    }
    
    @discardableResult func duplicate() -> Job {
        
        updateJobForSaving()
        try? context.save()
        
        let newJob: Job
        if let offer = job as? Offer {
            newJob = offer.duplicate(in: context)
        } else if let invoice = job as? Invoice {
            newJob = invoice.duplicate(in: context)
        } else {
            fatalError()
        }
        
        uploadJob(job: newJob, in: context)
        try? context.save()
        
        return newJob
    }
    
    @discardableResult func createInvoiceFromOffer() -> Invoice {
        
        updateJobForSaving()
        guard let offer = job as? Offer else {
            fatalError()
        }
        
        let invoice = Invoice.create(from: offer, in: context)
        
        uploadJob(job: invoice, in: context)
        try? context.save()
        
        return invoice
    }
    
    func nextFirstUserJourneyState() -> FirstUserJourneyState {
        if !job.isInserted {
            return .none
        }
        
        let currentState = FirstUserJourneyState.load()
        if (currentState == .addClient && clientSection.client != nil) ||
            (currentState == .addItem && itemSection.orders.count > 0) ||
            currentState == .showPreview {
            
            let nextState = currentState.next()
            nextState.save()
            
            return nextState
        }
        return currentState
    }
    
    
    private func donateJob() {
        if !job.isInserted {
            return
        }
        
        if #available(iOS 12.0, *) {
            
            /// We add the complete interaction with client and items
            guard let intent = job.createCreateIntent() else { return }
            let completeInteraction = INInteraction(intent: intent, response: nil)
            completeInteraction.donate { (error) in
                guard let error = error else {
                    return
                }
                logger.error(error)
                Crashlytics.sharedInstance().recordError(error)
            }
            
            /// We add the interaction with client and *no* items
            intent.items = nil
            let clientInteraction = INInteraction(intent: intent, response: nil)
            clientInteraction.donate { (error) in
                guard let error = error else {
                    return
                }
                logger.error(error)
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
}
