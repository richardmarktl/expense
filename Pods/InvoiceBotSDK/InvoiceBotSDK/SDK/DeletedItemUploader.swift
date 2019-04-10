//
//  Uploader.swift
//  InVoice
//
//  Created by Georg Kitz on 21/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio
import RxSwift

public class DeletedItemUploader {
    
    private let bag = DisposeBag()
    
    public init(with context: NSManagedObjectContext = CoreDataContainer.instance!.mainContext) {
        
        let deletedPredicate = NSPredicate(format: "(remoteId > 0 AND deletedTimestamp != NULL)")
        DeletedItemUploader.deleteOrders(in: context, with: deletedPredicate, bag: bag)
        DeletedItemUploader.deleteItems(in: context, with: deletedPredicate, bag: bag)
        DeletedItemUploader.deleteAttachments(in: context, with: deletedPredicate, bag: bag)
        DeletedItemUploader.deletePayments(in: context, with: deletedPredicate, bag: bag)
        DeletedItemUploader.deleteJobs(in: context, with: deletedPredicate, bag: bag)
    }
    
    private class func deleteOrders(in context: NSManagedObjectContext, with deletedPredicate: NSPredicate, bag: DisposeBag) {
        
        Order.rxAllObjects(matchingPredicate: deletedPredicate, context: context).filter({ $0.count != 0 }).subscribe(onNext: { (items) in

            var obs: Observable<Void> = Observable.just(())
            items.forEach({ (item) in
                obs = obs.concat(OrderRequest.delete(item).do(onNext: { item in
                    context.delete(item)
                }).mapToVoid()).catchErrorJustReturn(())
            })

            obs.takeLast(1).subscribe(onNext: { _ in
                //swiftlint:disable force_try
                context.perform {
                    try! context.save()
                }
                //swiftlint:enable force_try
            }).disposed(by: bag)

        }).disposed(by: bag)
    }
    
    private class func deleteItems(in context: NSManagedObjectContext, with deletedPredicate: NSPredicate, bag: DisposeBag) {
        
        Item.rxAllObjects(matchingPredicate: deletedPredicate, context: context).filter({ $0.count != 0 }).subscribe(onNext: { (items) in
            
            var obs: Observable<Void> = Observable.just(())
            items.forEach({ (item) in
                obs = obs.concat(ItemRequest.delete(item).do(onNext: { item in
                    context.delete(item)
                }).mapToVoid()).catchErrorJustReturn(())
            })
            
            obs.takeLast(1).subscribe(onNext: { _ in
                //swiftlint:disable force_try
                context.perform {
                    try! context.save()
                }
                //swiftlint:enable force_try
            }).disposed(by: bag)
            
        }).disposed(by: bag)
    }
    
    private class func deleteAttachments(in context: NSManagedObjectContext, with deletedPredicate: NSPredicate, bag: DisposeBag) {
        
        Attachment.rxAllObjects(matchingPredicate: deletedPredicate, context: context).filter({ $0.count != 0 }).subscribe(onNext: { (items) in
            
            var obs: Observable<Void> = Observable.just(())
            items.forEach({ (item) in
                obs = obs.concat(AttachmentRequest.delete(item).do(onNext: { item in
                    context.delete(item)
                }).mapToVoid()).catchErrorJustReturn(())
            })
            
            obs.takeLast(1).subscribe(onNext: { _ in
                //swiftlint:disable force_try
                context.perform {
                    try! context.save()
                }
                //swiftlint:enable force_try
            }).disposed(by: bag)
            
        }).disposed(by: bag)
    }
    
    private class func deletePayments(in context: NSManagedObjectContext, with deletedPredicate: NSPredicate, bag: DisposeBag) {
        
        Payment.rxAllObjects(matchingPredicate: deletedPredicate, context: context).filter({ $0.count != 0 }).subscribe(onNext: { (items) in
            
            var obs: Observable<Void> = Observable.just(())
            items.forEach({ (item) in
                obs = obs.concat(PaymentRequest.delete(item).do(onNext: { item in
                    context.delete(item)
                }).mapToVoid()).catchErrorJustReturn(())
            })
            
            obs.takeLast(1).subscribe(onNext: { _ in
                //swiftlint:disable force_try
                context.perform {
                    try! context.save()
                }
                //swiftlint:enable force_try
            }).disposed(by: bag)
            
        }).disposed(by: bag)
    }
    
    private class func deleteJobs(in context: NSManagedObjectContext, with deletedPredicate: NSPredicate, bag: DisposeBag) {
        
        let iObs = Invoice.rxAllObjects(matchingPredicate: deletedPredicate, context: context).map { items -> [Job] in return items }
        let oObs = Offer.rxAllObjects(matchingPredicate: deletedPredicate, context: context).map { items -> [Job] in return items }
        Observable.of(iObs, oObs).merge().filter({ $0.count != 0 }).subscribe(onNext: { (items) in

            var obs: Observable<Void> = Observable.just(())
            items.forEach({ (item) in
                obs = obs.concat(JobUploader.delete(item).do(onNext: { item in
                    context.delete(item)
                }).mapToVoid()).catchErrorJustReturn(())
            })

            obs.takeLast(1).subscribe(onNext: { _ in
                //swiftlint:disable force_try
                context.perform {
                    try! context.save()
                }
                //swiftlint:enable force_try
            }).disposed(by: bag)

        }).disposed(by: bag)
    }
}
