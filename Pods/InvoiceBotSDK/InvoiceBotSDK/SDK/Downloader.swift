//
//  Downloader.swift
//  InVoice
//
//  Created by Georg Kitz on 26/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio
import RxSwift

public enum DownloaderItem: String, Equatable {
    case none
    case clients
    case items
    case invoices
    case offers
    case invoiceOrders
    case offerOrders
    case invoiceAttachments
    case offerAttachments
    case payments
    case localizations
    case accountDetails
    case design
    case invoiceDefaults
    case offerDefaults

    static var allItems: [DownloaderItem] {
        return [
            none,
            clients,
            items,
            invoices,
            offers,
            invoiceOrders,
            offerOrders,
            invoiceAttachments,
            offerAttachments,
            payments,
            localizations,
            accountDetails,
            design,
            invoiceDefaults,
            offerDefaults
        ]
    }
    
//    var localizedString: String {
//        return R.string.localizable.loading(NSLocalizedString(self.rawValue, comment: ""))
//    }
    
    public func request(storage: UserDefaults = UserDefaults.standard, context: NSManagedObjectContext) -> Observable<DownloaderItem> {
        let storageKey = rawValue + "_last_loaded_date"
        let lastLoadedDate = storage.object(forKey: storageKey) as? Date
        let newLastLoadedDate = Date()
        return request(context, lastLoadedDate: lastLoadedDate)
            .do(onNext: { (_) in
                storage.set(newLastLoadedDate, forKey: storageKey)
                storage.synchronize()
            }).map({ (_) -> DownloaderItem in
                return self
            })
    }
    
    public func deleteStorageEntry(storage: UserDefaults = UserDefaults.standard) {
        let storageKey = rawValue + "_last_loaded_date"
        storage.removeObject(forKey: storageKey)
        storage.synchronize()
    }
    
    private func request(_ ctx: NSManagedObjectContext, lastLoadedDate: Date?) -> Observable<Void> {
        
        let lastLoadedDateString = lastLoadedDate?.ISO8601DateTimeString
        
        func wrappedRequest<T: BaseItem>(_ request: Observable<PagedResult<T>>) -> Observable<Void> {
            return request.takeLast(1).mapToVoid()
        }
        
        switch self {
        case .none:
            return Observable.just(())
        case .clients:
            return wrappedRequest(ClientRequest.load(updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .items:
            return wrappedRequest(ItemRequest.load(updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .invoices:
            return wrappedRequest(InvoiceRequest.load(updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .offers:
            return wrappedRequest(OfferRequest.load(updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .invoiceOrders:
            return wrappedRequest(OrderRequest.load(for: Path.offer, updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .offerOrders:
            return wrappedRequest(OrderRequest.load(for: Path.invoice, updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .invoiceAttachments:
            return wrappedRequest(AttachmentRequest.load(for: Path.offer, updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .offerAttachments:
            return wrappedRequest(AttachmentRequest.load(for: Path.invoice, updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .payments:
            return wrappedRequest(PaymentRequest.load(updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .localizations:
            return wrappedRequest(JobLocalizationRequest.load(updatedAfter: lastLoadedDateString, updateIn: ctx))
        case .accountDetails:
            let currentAccount = Account.current(context: ctx)
            return AccountRequest.load(currentAccount, updatedAfter: lastLoadedDateString, useDefaultMapper: true).mapToVoid()
        case .design:
            let jobDesign = JobDesign.current(in: ctx)
            return JobDesignRequest.load(jobDesign, updatedAfter: lastLoadedDateString).mapToVoid()
        case .invoiceDefaults:
            guard let invoiceDefaults = Defaults.currentDefaults(for: .invoice, in: ctx) else {
                return Observable.just(())
            }
            return DefaultsRequest.load(invoiceDefaults, updatedAfter: lastLoadedDateString).mapToVoid()
        case .offerDefaults:
            guard let offerDefaults = Defaults.currentDefaults(for: .offer, in: ctx) else {
                return Observable.just(())
            }
            return DefaultsRequest.load(offerDefaults, updatedAfter: lastLoadedDateString).mapToVoid()
        }
    }
    
    public var next: DownloaderItem {
        let all = DownloaderItem.allItems
        guard let index = all.lastIndex(of: self) else {
            return .none
        }
        
        if index == all.endIndex - 1 {
            return .none
        }
        return all[index + 1]
    }
}

public class Downloader {
    
    private let bag = DisposeBag()
    
    private struct Static {
        static var instance: Downloader?
    }
    
    public class var instance: Downloader? {
        get {
            if Static.instance != nil {
                return Static.instance
            }
            self.instance = Downloader()
            return self.instance
        }
        set {
            Static.instance = newValue
        }
    }
    
    private let curserSubject: Variable<String?> = Variable(nil)
    private let progressSubject: Variable<DownloaderItem> = Variable(.none)
    public var progressObservable: Observable<DownloaderItem> {
        return progressSubject.asObservable()
    }
    
    private var loadingObs: Observable<Void>?
    
    public func restoreFromBackup() -> Observable<Void> {
        DownloaderItem.allItems.forEach { (item) in
            item.deleteStorageEntry()
        }
        return download()
    }
    
    public func download() -> Observable<Void> {

        guard UserDefaults.appGroup.hasToken() else {
            return Observable.empty()
        }
        
        if let loadingObs = loadingObs {
            return loadingObs
        }
        
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        let ctx = CoreDataContainer.instance!.newBackgroundContext()
        
        self.curserSubject.value = nil
        self.progressSubject.value = .clients
        
        let obs = Observable.just(DownloaderItem.clients).observeOn(background)
        
        let allItems = DownloaderItem.allItems.dropFirst();
        let allRequests = allItems.map { $0.request(context: ctx) }
        let loadObs = Observable
            .concat(allRequests)
            .do(onNext: { [weak self](currentItem) in
                self?.progressSubject.value = currentItem.next
                logger.debug("Next item \(currentItem.next)")
            })
        
        let chainedObs = obs
            .concat(loadObs)
            .takeLast(1)
            .do(onNext: { [weak self](_) in
                self?.loadingObs = nil
                try? ctx.save()
            })
        .mapToVoid()
        
        self.loadingObs = chainedObs
        return chainedObs
    }
}
