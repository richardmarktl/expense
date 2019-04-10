//
//  JobUploader.swift
//  InVoice
//
//  Created by Georg Kitz on 22/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

public struct JobUploader {
    
    /// This method will first upload the invoice of offer itself.
    /// After that it will create the sub resources or update them.
    ///
    /// - Parameters:
    ///   - job: the invoice or offer
    ///   - changedOrders: changed orders
    ///   - changedAttachments: changed attachments
    ///   - changedPayments: changed payments
    /// - Returns: a Observable returning a job
    public static func upload(_ job: Job, changedOrders: [Order], changedAttachments: [Attachment], changedPayments: [Payment]) -> Observable<Job> {
        // Upload job first
        var obs: Observable<Job>
        if let offer = job as? Offer, job.hasChanges {
            obs = OfferRequest.upload(offer).take(1).map({ (item) -> Job in
                return item
            })
        } else if let invoice = job as? Invoice, job.hasChanges {
            obs = InvoiceRequest.upload(invoice).take(1).map({ (item) -> Job in
                return item
            })
        } else {
            obs = Observable.just(job)
        }

        return uploadResources(observable: obs, orders: changedOrders, attachments: changedAttachments, payments: changedPayments)
    }
    
    /// This method will first upload the pdf and the invoice of offer itself.
    /// After that it will create the sub resources or update them.
    ///
    /// - Parameters:
    ///   - job: the invoice or offer
    ///   - sendTo: the recipients where to send the invoice/offer pdf
    ///   - changedOrders: changed orders
    ///   - changedAttachments: changed attachments
    ///   - changedPayments: changed payments
    /// - Returns: a Observable returning a job
    public static func upload(_ job: Job, sendTo: MailParameter, changedOrders: [Order], changedAttachments: [Attachment], changedPayments: [Payment]) -> Observable<Job> {
        return uploadResources(
            observable: MailRequest.sendJob(job, mail: sendTo),
            orders: changedOrders,
            attachments: changedAttachments,
            payments: changedPayments
        )
    }
    
    /// The method uploadResources will upload the dependencies of an invoice or an offer object.
    ///
    /// - Parameters:
    ///   - observable: a Observable
    ///   - orders: changed orders
    ///   - attachments: changed attachments
    ///   - payments: changed payments
    /// - Returns: a Observable returning a job
    public static func uploadResources(observable: Observable<Job>, orders: [Order], attachments: [Attachment], payments: [Payment]) -> Observable<Job> {
        var obs: Observable<Job> = observable

        // Upload orders next
        if orders.count > 0 {
            obs = obs.flatMap { (job) -> Observable<Job> in
                return OrderRequest.upload(orders, for: job).takeLast(1).map({ (_) -> Job in
                    return job
                }).catchErrorJustReturn(job)
            }
        }
        
        // upload payments
        if payments.count > 0 {
            obs = obs.flatMap { (job) -> Observable<Job> in
                return PaymentRequest.upload(payments, for: job).takeLast(1).map({ (_) -> Job in
                    return job
                }).catchErrorJustReturn(job)
            }
        }
        
        // Upload changed attachments next
        if attachments.count > 0 {
            obs = obs.flatMap { (job) -> Observable<Job> in
                return AttachmentRequest.upload(attachments, for: job).takeLast(1).map({ (_) -> Job in
                    return job
                }).catchErrorJustReturn(job)
            }
        }
        
        return obs.takeLast(1)
    }
    
    /// This will delete the invoice on the server. Sub resources will be deleted by the api itself.
    ///
    /// - Parameter job: an invoice or an offer
    /// - Returns: an observable with the deleted job
    public static func delete(_ job: Job) -> Observable<Job> {
        var obs: Observable<Job>
        if let offer = job as? Offer {
            obs = OfferRequest.delete(offer).map({ (item) -> Job in
                return item
            })
        } else if let invoice = job as? Invoice {
            obs = InvoiceRequest.delete(invoice).map({ (item) -> Job in
                return item
            })
        } else {
            obs = Observable.just(job)
        }
        
        return obs.take(1)
    }
}
