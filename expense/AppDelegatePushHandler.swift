//
//  AppDelegatePushHandler.swift
//  InVoice
//
//  Created by Georg Kitz on 05/02/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import Horreum
import RxSwift

enum PushError: Error {
    case unsupportedAPNType
    case parameter
}

enum APNType: String {
    case trackingStateChanged = "tracking_changed"
    case invoicePaid = "invoice_paid"
    case invoiceOverdue = "invoice_overdue"
    case monthlyRevenue = "monthly_revenue"
    case apiUpdated = "api_updated"
}

struct AppDelegatePushHandler {
    
    static func handle(userInfo: [AnyHashable: Any]) -> Observable<Void> {
        guard let typeString = userInfo["type"] as? String, let type = APNType(rawValue: typeString) else {
            logger.error("Unsupported APN Type: \(userInfo)")
            return Observable.error(PushError.unsupportedAPNType)
        }
        
        switch type {
        case .apiUpdated:
            return handleApiUpdate()
        case .trackingStateChanged:
            return handleTrackingUpdate(with: userInfo)
        case .invoicePaid:
            return handleInvoicePaid(with: userInfo)
        case .invoiceOverdue, .monthlyRevenue:
            return handleOpenning(of: type)
        }
    }
    
    static private func handleOpenning(of apnType: APNType) -> Observable<Void> {
        return Observable.just(())
            .do(onNext: { (_) in
                DispatchQueue.main.async {
                    AppDelegatePushHandler.open(path: apnType.rawValue)
                }
            })
            .take(1)
    }
    
    static private func handleInvoicePaid(with userInfo: [AnyHashable: Any]) -> Observable<Void> {
        guard let remoteIdString = userInfo["id"] as? String,
            let remoteId = Int64(remoteIdString) else {
                logger.error("Invoice Paid Update has wrong parameters")
                return Observable.error(PushError.parameter)
        }
        
        let ctx = Horreum.instance!.childContext()
        return InvoiceRequest.load(with: remoteId, context: ctx).flatMap { (_) -> Observable<Void> in
            return PaymentRequest.load(for: remoteId, updatedAfter: nil, updateIn: ctx).takeLast(1).mapToVoid()
        }.do(onNext: { _ in
            try? ctx.save()
            DispatchQueue.main.async {
                AppDelegatePushHandler.open(type: "invoice", jobId: remoteId)
            }
        }).take(1)
    }
    
    static private func handleTrackingUpdate(with userInfo: [AnyHashable: Any]) -> Observable<Void> {
        guard let itemTypeString = userInfo["item"] as? String,
            let itemType = Path(rawValue: itemTypeString),
            let remoteIdString = userInfo["id"] as? String,
            let remoteId = Int64(remoteIdString) else {
                logger.error("Tracking Update has wrong parameters")
                return Observable.error(PushError.parameter)
        }
        
        let ctx = Horreum.instance!.childContext()
        let obs: Observable<Void>
        if itemType == .invoice {
            obs = InvoiceRequest.load(with: remoteId, context: ctx).mapToVoid()
        } else {
            obs = OfferRequest.load(with: remoteId, context: ctx).mapToVoid()
        }
        
        return obs.do(onNext: { _ in
            try? ctx.save()
            DispatchQueue.main.async {
                AppDelegatePushHandler.open(type: itemType.rawValue, jobId: remoteId)
            }
        }).take(1)
    }
    
    static private func handleApiUpdate() -> Observable<Void> {
        guard let downloader = Downloader.instance else {
            return Observable.empty()
        }
        
        return downloader.download().do(onNext: { (_) in
            logger.verbose("Download finished, was triggered by a push")
        })
    }
    
    /// This is a helper function that actually triggers an url open to open the controller we want.
    /// Opened will be the job controller for an invoice/order with a specific idea
    /// - Parameters:
    ///   - type: of controller we want to open
    ///   - jobId: id of the job
    static private func open(type: String, jobId: Int64) {
        let path = "\(type)/\(jobId)"
        open(path: path)
    }
    
    static private func open(path: String) {
        let scheme = Bundle.main.infoDictionary!["URL_SCHEME_PROTOCOL"] as? String ?? ""
        let jobRoute = scheme + "://bot/" + path
        guard let url = URL(string: jobRoute) else {
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
}
