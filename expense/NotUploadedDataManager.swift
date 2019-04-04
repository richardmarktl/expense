//
//  NotUploadedDataManager.swift
//  InVoice
//
//  Created by Georg Kitz on 18/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

enum Uploaded {
    case invoice(Int)
    case offer(Int)
    case client(Int)
    case item(Int)
    case order(Int)
    case attachment(Int)
    case payment(Int)
}

struct NotUploadedDataManager {
    
    fileprivate let bag = DisposeBag()
    
    init(online: Observable<Bool> = reachabilityColsure(), delay: RxTimeInterval = 10, context: NSManagedObjectContext, updatedClosure: @escaping ((Uploaded) -> Void)) {
        
        online.filter { $0 == true }.mapToVoid().delay(delay, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap {
                return uploadAllUnsyncedClients(context, updateClosure: updatedClosure)
            }
            .flatMap {
                return uploadAllUnsyncedItems(context, updateClosure: updatedClosure)
            }
            .flatMap {
                return uploadAllUnsyncedJobs(context, updateClosure: updatedClosure)
            }
            .flatMap {
                return uploadAllUnsyncedOrders(context, updateClosure: updatedClosure)
            }
            .flatMap {
                return uploadAllUnsyncedOrders(context, updateClosure: updatedClosure)
            }
            .flatMap {
                return uploadAllUnsyncedAttachments(context, updateClosure: updatedClosure)
            }
            .flatMap {
                return uploadAllUnsyncedPayments(context, updateClosure: updatedClosure)
            }
            .subscribe { (event) in
                
                print("UNUPLOADED UPLOADER: \(event)")
                try? context.save()
                
            }.disposed(by: bag)
        
    }
}

private func uploadAllUnsyncedClients(_ context: NSManagedObjectContext, updateClosure:@escaping ((Uploaded) -> Void)) -> Observable<Void> {
    
    let items = Client.notUploaded(in: context)
    var observable = Observable.just(())
    
    items.forEach { (item) in
        observable = observable.concat(ClientRequest.upload(item).mapToVoid().catchErrorJustReturn(()))
    }
    
    return observable.takeLast(1).map {
        
        try context.save()
        
        if items.count > 0 {
            updateClosure(Uploaded.client(items.count))
        }
    }
}

private func uploadAllUnsyncedJobs(_ context: NSManagedObjectContext, updateClosure:@escaping ((Uploaded) -> Void)) -> Observable<Void> {
    
    let offerItems = Offer.notUploaded(in: context)
    var observable = Observable.just(())
    
    func loadJobNumberIfNeeded(for item: Job, request: Observable<String>) -> Observable<Void> {
        guard let jobNumber = item.number, jobNumber == JobNumber.invalidJobNumber.value else {
            return Observable.just(())
        }
        
        let jobNumberModel = JobNumberModel(loadJobNumberObservable: request, reachabilityObservable: Observable.just(true))
        return jobNumberModel.jobNumberObservable.do(onNext: { (jobNumber: JobNumber) in
            item.number = jobNumber.value
        }).mapToVoid()
    }
    
    offerItems.forEach { (item) in
        observable = observable.concat(loadJobNumberIfNeeded(for: item, request: OfferRequest.next())).concat(OfferRequest.upload(item).mapToVoid().catchErrorJustReturn(()))
    }
    
    let invoiceItems = Invoice.notUploaded(in: context)
    invoiceItems.forEach { (item) in
        observable = observable.concat(loadJobNumberIfNeeded(for: item, request: InvoiceRequest.next())).concat(InvoiceRequest.upload(item).mapToVoid().catchErrorJustReturn(()))
    }
    
    return observable.takeLast(1).map {
        
        try context.save()
        
        if offerItems.count > 0 || invoiceItems.count > 0 {
            updateClosure(Uploaded.invoice(offerItems.count + invoiceItems.count))
        }
    }
}

private func uploadAllUnsyncedOrders(_ context: NSManagedObjectContext, updateClosure:@escaping ((Uploaded) -> Void)) -> Observable<Void> {
    
    let items = Order.notUploaded(in: context)
    var observable = Observable.just(())
    
    items.forEach { (item) in
        if let job = item.item {
            observable = observable.concat(OrderRequest.upload(item, for: job).mapToVoid().catchErrorJustReturn(()))
        }
    }
    
    return observable.takeLast(1).map {
        
        try context.save()
        
        if items.count > 0 {
            updateClosure(Uploaded.order(items.count))
        }
    }
}

private func uploadAllUnsyncedAttachments(_ context: NSManagedObjectContext, updateClosure:@escaping ((Uploaded) -> Void)) -> Observable<Void> {
    
    let items = Attachment.notUploaded(in: context)
    var observable = Observable.just(())
    
    items.forEach { (item) in
        if let job = item.job {
            observable = observable.concat(AttachmentRequest.upload(item, for: job).mapToVoid().catchErrorJustReturn(()))
        }
    }
    
    return observable.takeLast(1).map {
        
        try context.save()
        
        if items.count > 0 {
            updateClosure(Uploaded.attachment(items.count))
        }
    }
}

private func uploadAllUnsyncedPayments(_ context: NSManagedObjectContext, updateClosure:@escaping ((Uploaded) -> Void)) -> Observable<Void> {
    
    let items = Payment.notUploaded(in: context)
    var observable = Observable.just(())
    
    items.forEach { (item) in
        if let job = item.invoice {
            observable = observable.concat(PaymentRequest.upload(item, for: job).mapToVoid().catchErrorJustReturn(()))
        }
    }
    
    return observable.takeLast(1).map {
        
        try context.save()
        
        if items.count > 0 {
            updateClosure(Uploaded.payment(items.count))
        }
    }
}

private func uploadAllUnsyncedItems(_ context: NSManagedObjectContext, updateClosure:@escaping ((Uploaded) -> Void)) -> Observable<Void> {
    
    let items = Item.notUploaded(in: context)
    var observable = Observable.just(())
    
    items.forEach { (item) in
        observable = observable.concat(ItemRequest.upload(item).mapToVoid().catchErrorJustReturn(()))
    }
    
    return observable.takeLast(1).map {
        
        try context.save()
        
        if items.count > 0 {
            updateClosure(Uploaded.item(items.count))
        }
    }
}
