//
//  ThemeModel.swift
//  InVoice
//
//  Created by Georg Kitz on 05/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import Horreum
import RxSwift
import SwiftMoment

class ThemeModel: DetailModel<Account> {
    
    let templateSection: TemplateSection
    let personalizeSection: PersonalizeSection
    let attachmentSection: AttachmentSection
    let pageSizeSection: PageSizeSection
    let itemSection: ItemSection
    
    let rendererContext: NSManagedObjectContext
    
    private(set) var job: Job?
    private(set) var renderer: PerformanceInvoiceGenerator?
    
    var attachmentFullWidthEnabledObservable: Observable<Bool> {
        return attachmentSection.fullWidthItemObservable.filterTrue()
    }
    
    required init(item: Account, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [Section], in context: NSManagedObjectContext) {
        
        rendererContext = Horreum.instance!.childContext()
        templateSection = TemplateSection(design: item.design!)
        personalizeSection = PersonalizeSection(item: item)
        pageSizeSection = PageSizeSection(design: item.design!)
        attachmentSection = AttachmentSection(design: item.design!)
        itemSection = ItemSection(design: item.design!)
        
        super.init(item: item, storeChangesAutomatically: true, deleteAutomatically: true,
                   sections: [personalizeSection, templateSection, pageSizeSection, attachmentSection, itemSection], in: context)
        
        job = insertSampleData(for: item, in: rendererContext)
        
        Observable.combineLatest(
            JobDesign.rxAllObjects(matchingPredicate: NSPredicate.undeletedItem(), fetchLimit: 1, context: context),
            JobLocalization.rxAllObjects(matchingPredicate: NSPredicate.undeletedItem(), context: context)
        ) { (designs, localizations) -> Void in
            guard let item = designs.first, let template = item.template, let color = item.color, let job = self.job else { return }
            self.renderer = PerformanceInvoiceGenerator(job: job, template: template, color: color, observeChangesIn: self.rendererContext)
        }.subscribe().disposed(by: bag)
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError("init(with:) has not been implemented")
    }
    
    //swiftlint:disable function_body_length
    private func insertSampleData(for item: Account, in context: NSManagedObjectContext) -> Job {
        
        let company: Account
        if let currentCompany = Account.allObjects(context: context).first {
            company = currentCompany
        } else {
            company = Account(inContext: context)
            company.name = R.string.localizable.companyName()
            company.address = R.string.localizable.companyAddress()
            company.email = R.string.localizable.companyEmail()
            company.phone = R.string.localizable.companyPhone()
            company.website = R.string.localizable.companyWebsite()
            company.taxId = R.string.localizable.companyTaxId()
            company.paymentDetails = R.string.localizable.companyPaymentDetails()
            company.note = R.string.localizable.companyNote()
            company.uuid = UUID().uuidString.lowercased()
            company.createdTimestamp = Date()
            company.updatedTimestamp = Date()
        }
        
        let client = Client(inContext: context)
        client.name = R.string.localizable.clientName().sampleHintReplaced
        client.address = R.string.localizable.clientName().asSampleEmailAddress
        client.email = R.string.localizable.clientEmail()
        client.phone = R.string.localizable.clientPhone()
        client.taxId = R.string.localizable.clientTaxId()
        client.uuid = UUID().uuidString.lowercased()
        client.createdTimestamp = Date()
        client.updatedTimestamp = Date()
        
        let invoice = Invoice(inContext: context)
        invoice.uuid = UUID().uuidString.lowercased()
        invoice.number = R.string.localizable.inv() + "666999"
        invoice.createdTimestamp = Date()
        invoice.updatedTimestamp = Date()
        invoice.date = Date()
        invoice.language = Locale.current.languageCode
        if let paymentDetails = item.paymentDetails, !paymentDetails.isEmpty {
            invoice.paymentDetails = paymentDetails
        } else {
            invoice.paymentDetails = R.string.localizable.samplePaymentDetails()
        }
        
        if let note = item.note, !note.isEmpty {
            invoice.note = note
        } else {
            invoice.note = R.string.localizable.sampleNoteDetails()
        }

        invoice.dueTimestamp = moment().add(7, TimeUnit.Days).date
        invoice.total = NSDecimalNumber(value: 1250.50)
        invoice.discount = NSDecimalNumber.zero
        invoice.isDiscountAbsolute = true
        invoice.client = client
        invoice.update(from: client)
        
        let item = Item(inContext: context)
        item.createdTimestamp = moment().date
        item.updatedTimestamp = moment().date
        item.itemDescription = R.string.localizable.itemDescription().sampleHintReplaced
        item.title = R.string.localizable.itemDescription().sampleHintReplaced.split(separator: " ").first.map(String.init)
        item.price = NSDecimalNumber(value: 120)
        item.tax = NSDecimalNumber(value: 20)
        
        [0,1,2].forEach { (_) in
            let order = Order(inContext: context)
            order.uuid = UUID().uuidString.lowercased()
            order.number = order.uuid?.shortenedUUIDString
            order.discount = NSDecimalNumber.zero
            order.quantity = NSDecimalNumber(value: 1)
            order.price = item.price
            order.tax = item.tax
            order.title = item.title
            order.itemDescription = item.itemDescription
            order.item = invoice
            order.template = item
            
            order.calculateTotal()
            
            order.item = invoice
        }
        
        let filename = "92953B8B-BEBB-4B39-934D-44349F51869F"
        let obs: Observable<ImageStorageItem>
        if !ImageStorage.hasItemStoredOnFileSystem(filename: filename) {
            let image = R.image.sampleAttachment()!
            obs = ImageStorage.storeImage(originalImage: image, filename: filename)
        } else {
            obs = ImageStorage.loadImage(for: filename)
        }
        
        _ = obs.take(1).subscribe(onNext: { (storeItem) in
            let attachment = Attachment(inContext: context)
            attachment.localUpdateTimestamp = moment().date
            attachment.createdTimestamp = moment().date
            attachment.updatedTimestamp = moment().date
            attachment.fileName = "Sample Attachment"
            attachment.uuid = filename
            attachment.path = storeItem.imagePath
            attachment.thumbPath = storeItem.thumbnailPath
            attachment.job = invoice
        })
        
        return invoice
    }
    
    func uploadDesign() -> Observable<Void> {
        guard let design = JobDesign.allObjects(matchingPredicate: NSPredicate.undeletedItem(), fetchLimit: 1, context: context).first else {
            return Observable.error("No Design found")
        }
        return JobDesignRequest.upload(design).mapToVoid()
    }
    //swiftlint:enable function_body_length
}
