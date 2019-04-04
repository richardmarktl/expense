//
//  OfferModel.swift
//  InVoice
//
//  Created by Georg Kitz on 12/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

/// MARK: -
/// Base Item to display the data in the cell
class JobItem: ViewItem<Job> {
    
    let externalId: String
    let client: String
    let total: Float
    let totalString: String
    let state: JobState
    fileprivate(set) var timeString: String = ""
    
    override init(item: Job) {
        
        let languageAddition: String
        if let itemLanguage = item.language?.asLanguage,
            let currentLanguageCode = Locale.current.languageCode?.asLanguage,
            itemLanguage != currentLanguageCode {
            languageAddition = " " + itemLanguage.shortDesignName
        } else {
            languageAddition = ""
        }
        
        externalId = (item.number ?? "") + item.referenceRelationId + languageAddition
        client = item.clientName ?? ""
        total = item.total?.floatValue ?? 0
        totalString = item.total?.asCurrency(currencyCode: item.currency) ?? ""
        timeString = item.date?.asString(.medium, timeStyle: .none) ?? ""
        state = item.typedState
        super.init(item: item)
    }
}

/// Specific offer item
class OfferItem: JobItem {
    init(offer: Offer) {
        super.init(item: offer)
        guard let sent = offer.sentTimestamp?.relativeString(prefixedWith: R.string.localizable.prefixSent()) else {
            return
        }
        timeString += ", " + sent
    }
}

/// Specific invoice item
class InvoiceItem: JobItem {
    init(invoice: Invoice) {
        super.init(item: invoice)
        
        guard let due = invoice.dueTimestamp?.relativeString(prefixedWith: R.string.localizable.prefixDue()) else {
            return
        }
        
        timeString += ", " + due
    }
}

/// Specific paid invoice item
class PaidInvoice: JobItem {
    init(invoice: Invoice) {
        super.init(item: invoice)
        
        guard let paid = invoice.paidTimestamp?.relativeString(prefixedWith: R.string.localizable.prefixPaid()) else {
            return
        }
        
        timeString += ", " + paid
    }
}

/// MARK: -
/// Helper to abstract the different variants off how we load the data from the database
struct JobItemObservables {
    
    /// Loads all available offers
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func offerObservable(in context: NSManagedObjectContext) -> Observable<[JobItem]> {
        return Offer.rxAllObjects(matchingPredicate: NSPredicate.undeletedItem(), context: context).map { offers in
            return offers.map { OfferItem(offer: $0) }
        }
    }
    
    /// Loads all available invoices which aren't paid yet, they aren't necessarily sent either
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func invoiceObservable(in context: NSManagedObjectContext) -> Observable<[JobItem]> {
        return Invoice.rxAllObjects(matchingPredicate: NSPredicate.openInvoices(), context: context).map { offers in
            return offers.map { InvoiceItem(invoice: $0) }
        }
    }
    
    /// Loads all available invoices which aren't paid yet
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func unpaidInvoiceObservable(in context: NSManagedObjectContext) -> Observable<[JobItem]> {
        return Invoice.rxAllObjects(matchingPredicate: NSPredicate.unpaidInvoices(), context: context).map { offers in
            return offers.map { InvoiceItem(invoice: $0) }
        }
    }
    
    /// Loads all available invoices which aren't paid yet
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func overdueInvoiceObservable(in context: NSManagedObjectContext) -> Observable<[JobItem]> {
        return Invoice.rxAllObjects(matchingPredicate: NSPredicate.overdueInvoices(), context: context).map { offers in
            return offers.map { InvoiceItem(invoice: $0) }
        }
    }
    
    /// Loads all available invoices which aren't paid yet
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func overdueTomorrowInvoiceObservable(in context: NSManagedObjectContext) -> Observable<[JobItem]> {
        return Invoice.rxAllObjects(matchingPredicate: NSPredicate.overdueTomorrowInvoices(), context: context).map { offers in
            return offers.map { InvoiceItem(invoice: $0) }
        }
    }
    
    /// Loads all available invoices which aren't paid yet
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func unsentInvoiceObservable(in context: NSManagedObjectContext) -> Observable<[JobItem]> {
        return Invoice.rxAllObjects(matchingPredicate: NSPredicate.unsentInvoices(), context: context).map { offers in
            return offers.map { InvoiceItem(invoice: $0) }
        }
    }
    
    /// Loads all available invoices which aren't opened by the receiver yet
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func unopenedInvoiceObservable(in context: NSManagedObjectContext) -> Observable<[JobItem]> {
        return Invoice.rxAllObjects(matchingPredicate: NSPredicate.unopenedInvoices(), context: context).map { offers in
            return offers.map { InvoiceItem(invoice: $0) }
        }
    }
    
    /// Loads all available invoices that are paid
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func paidInvoiceObservable(in context: NSManagedObjectContext) -> Observable<[JobItem]> {
        return Invoice.rxAllObjects(matchingPredicate: NSPredicate.paidInvoices(), context: context).map { offers in
            return offers.map { PaidInvoice(invoice: $0) }
        }
    }
}

/// MARK: -
/// Model that combines the data loading + searching
class JobItemModel {
    
    private let bag = DisposeBag()
    
    private let jobItemSubject: Variable<[JobItem]> = Variable([])
    var jobItemObservable: Observable<[JobItem]> {
        return jobItemSubject.asObservable()
    }
    
    var jobItems: [JobItem] {
        return jobItemSubject.value
    }

    /// Model that combines the data loading + searching
    ///
    /// - Parameters:
    ///   - searchObservable: observable which changes when the searchstring changes
    ///   - loadObservable: data load observable
    init(searchObservable: Observable<String>, loadObservable: Observable<[JobItem]>) {
        
        Observable.combineLatest(loadObservable, searchObservable) { (obs, obs2) in
            return (obs, obs2)
        }
        .map { (offers, searchString) -> [JobItem] in
            
            let trimmedSearchString = searchString.asSearchString
            
            if trimmedSearchString.count == 0 {
                return offers
            }
            return offers.filter({ (offer) -> Bool in 
                return offer.externalId.lowercased().contains(trimmedSearchString) || offer.client.lowercased().contains(trimmedSearchString)
            })
        }
        .bind(to: jobItemSubject)
        .disposed(by: bag)
    }
    
    func indexOf(job: Job) -> Int? {
        for (index, item) in jobItems.enumerated() where item.item.uuid == job.uuid {
            return index
        }
        return nil
    }
}
