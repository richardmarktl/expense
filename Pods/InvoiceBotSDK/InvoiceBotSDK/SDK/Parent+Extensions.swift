//
//  Parent+Extensions.swift
//  InVoice
//
//  Created by Georg Kitz on 27/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional
import CoreData
import CoreDataExtensio
import ImageStorage

public enum JobState: Int32 {
    case notSend
    case sent
    case deferral
    case bounced
    case softBounce
    case opened
    case rejected
    case invalid
    case downloaded
    case paid
    case signed
}

extension Job {
    
    public var ordersTyped: [Order] {
        return orders?.allObjects as? [Order] ?? []
    }
    
    public var changedOrders: [Order] {
        
        guard let ctx = managedObjectContext else {
            return []
        }
        
        let inserted = ctx.insertedObjects.filter { $0 is Order } as? Set<Order> ?? Set<Order>()
        let updated = ctx.updatedObjects.filter { $0 is Order } as? Set<Order> ?? Set<Order>()
        
        return Array(inserted.union(updated)).filter({ $0.hasPersistentChangedValues && $0.deletedTimestamp == nil })
    }
    
    public var changedAttachements: [Attachment] {
        guard let ctx = managedObjectContext else {
            return []
        }
        
        let inserted = ctx.insertedObjects.filter { $0 is Attachment } as? Set<Attachment> ?? Set<Attachment>()
        let updated = ctx.updatedObjects.filter { $0 is Attachment } as? Set<Attachment> ?? Set<Attachment>()
        
        return Array(inserted.union(updated)).filter({ $0.hasPersistentChangedValues && $0.deletedTimestamp == nil })
    }
    
    public var changedPayments: [Payment] {
        guard let ctx = managedObjectContext else {
            return []
        }
        
        let inserted = ctx.insertedObjects.filter { $0 is Payment } as? Set<Payment> ?? Set<Payment>()
        let updated = ctx.updatedObjects.filter { $0 is Payment } as? Set<Payment> ?? Set<Payment>()
        
        return Array(inserted.union(updated)).filter({ $0.hasPersistentChangedValues && $0.deletedTimestamp == nil })
    }
    
    public var attachmentTyped: [Attachment] {
        return attachments?.allObjects as? [Attachment] ?? []
    }
    
    public var recipientsTyped: [Recipient] {
        return recipients?.allObjects as? [Recipient] ?? []
    }
    
//    var localizedType: String {
//        return self is Invoice ? R.string.localizable.invoiceTitle() : R.string.localizable.offer()
//    }
//    
//    var localizedTypeKey: String {
//        return self is Invoice ? R.string.localizable.invoiceTitle.key : R.string.localizable.offerTitle.key
//    }
//    
//    var localizedTypeNumberKey: String {
//        return self is Invoice ? R.string.localizable.invoiceNumberTitle.key : R.string.localizable.offerNumberTitle.key
//    }
//    
//    var localizedTypeInMiddleOfSentence: String {
//        return self is Invoice ? R.string.localizable.invoiceMiddleSentence() : R.string.localizable.offerMiddleSentence()
//    }
//    
//    var localizedTypeInMiddleOfSentenceKey: String {
//        return self is Invoice ? R.string.localizable.invoiceMiddleSentence.key : R.string.localizable.offerMiddleSentence.key
//    }
    
    public var referenceRelationId: String {
        if let invoice = self as? Invoice, let number = invoice.offer?.number {
            return " ‹ " + number
        } else if let offer = self as? Offer, let number = offer.invoice?.number {
            return " › " + number
        }
        return ""
    }
    
    public var typedState: JobState {
        return JobState(rawValue: state) ?? .notSend
    }
    
//    var shareableName: String {
//        let externalId = (number ?? "")
//        return localizedType + " " + externalId + ".pdf"
//    }
    
    
    /// This will return true if the signedOn property is set or the signature string is set. The signedOn
    /// property used as indicator for the local signature file. 
    public var hasSignature: Bool {
        return signedOn != nil || signature != nil
    }
    
    public var isSigned: Bool {
        var signed = false
        recipientsTyped.forEach { (recipient) in
            signed = signed || recipient.typedState == .signed
        }
        return signed
    }
    
    /// The prefix is used to make it easier for us to find the signature in the image folder.
    /// us_<uuid> is short for (u)ser (s)ignature.
    public var signatureImageName: String? {
        if let uuid = uuid {
            return "us_" + uuid
        }
        return nil
    }
    
    public func rxChangesOnSelf(in context: NSManagedObjectContext) -> Observable<Job> {
        if self is Invoice {
            return Invoice.rxMonitorChanges(context).map({ (data) -> Job? in
                return data.updated.first
            }).filterNil()
        } else {
            return Offer.rxMonitorChanges(context).map({ (data) -> Job? in
                return data.updated.first
            }).filterNil()
        }
    }
    
    
    /// This method checks if the signature param changed and if so it will update the corresponding
    /// signedOn field.
    public func updateSignature() {
        let key = "signature"
        if let newValue = self.changedValues()[key] {
            if newValue as? NSNull == NSNull() {
                // the signature was deleted on the server remove the local version of it.
                if let fileName = self.signatureImageName {
                    ImageStorage.deleteImage(in: FileSystemDirectory.imageAttachments, for: fileName)
                }
                self.signedOn = nil  // also clear the signedOn property
            }
        }
    }
    
    public func update(from client: Client?) {
        clientName = client?.name.databaseValue
        clientEmail = client?.email.databaseValue
        clientPhone = client?.phone.databaseValue
        clientTaxId = client?.taxId.databaseValue
        clientAddress = client?.address.databaseValue
        clientWebsite = client?.website.databaseValue
        clientNumber = client?.number.databaseValue
    }
    
    func parameters() throws -> JobParameter {
        guard let uuid = uuid,
            let number = number,
            let date = date?.ISO8601DateTimeString,
            let discount = discount?.asRounded().asPosixString(),
            let total = total?.asRounded().asPosixString() else {
                throw ApiError.parameter
        }
        
        var error: String = ""
        if language == nil {
            language = Locale.current.languageCode
            error += "Language was updated manually set to \(String(describing: language)) uuid: \(uuid)"
        }
        
        if currency == nil {
            currency = Locale.current.currencyCode
            error += "Currency was update manually to \(String(describing: currency)) uuid: \(uuid)"
        }
        
        if !error.isEmpty {
            //            TODO:
//            #if !IS_EXTENSION
//            Crashlytics.sharedInstance().recordError(error)
//            #endif
        }
        
        var clientParameters: ClientParameter?
        if let client = client, let uuid = client.uuid {
            clientParameters = (
                uuid: uuid,
                number: client.number,
                name: client.name,
                phone: client.phone,
                taxId: client.taxId,
                email: client.email,
                website: client.website,
                address: client.address,
                isActive: client.isActive
            )
        }
        
        return (
            uuid: uuid,
            number: number,
            date: date,
            discount: discount,
            isDiscountAbsolute: isDiscountAbsolute,
            total: total,
            state: state,
            paymentDetails: paymentDetails,
            note: note,
            language: language,
            currency: currency,
            clientRemoteId: client?.remoteId,
            client: clientParameters,
            signature: nil,
            signedOn: signedOn?.ISO8601DateTimeString,
            signatureName: signatureName,
            signatureUpdate: .none,
            needsSignature: needsSignature
        )
    }
    
    /// This method will try to load the user signature, the user signature loads different than the recipient method
    /// because the signature of the user is can be created on the device. The Recipient signature is always created
    /// not on the device.
    ///
    /// - Returns: an observable for the signature
    public func loadUserSignature() -> Observable<ImageStorageItem> {
        if UITestHelper.isUITesting {
            return ImageStorage.loadImage(in: FileSystemDirectory.imageAttachments,for: "userSignature")
        }
        
        guard let localSignatureName = signatureImageName else {
            return Observable.error(SignatureError.failed(with: "The local signature name was not set."))
        }
        
        if ImageStorage.hasItemStoredOnFileSystem(in: FileSystemDirectory.imageAttachments, filename: localSignatureName) {
            return ImageStorage.loadImage(in: FileSystemDirectory.imageAttachments, for: localSignatureName)
        } else if let signature = signature {
            return ImageStorage.download(fromURL: signature, filename: localSignatureName, storeIn: FileSystemDirectory.imageAttachments)
        }
        
        return Observable.error(SignatureError.failed(with: "The local signature was not found and no url was set."))
    }
    
    
    /// This method will load the the signature from the file system in the case,
    /// signedOn is set and the signature path property is not set, then we need to
    /// update it.
    ///
    /// - Returns: an observable with the signature and the update state.
    public func needsSignatureUpdate() -> Observable<(Data?, FileUpdate)> {
        if signedOn != nil {
            // no signature set, so we need an upload
            if signature == nil, let path = signatureImageName {
                return ImageStorage.loadImage(in: FileSystemDirectory.imageAttachments, for: path).map({ (storageItem) -> (Data?, FileUpdate) in
                    return (storageItem.image.pngData(), .update)
                })
            }
            // both set, nothing to do here
            return Observable.just((nil, .none))
        }
        // no local path anymore the signature was deleted.
        return Observable.just((nil, .update))
    }
    
    public var shouldShowCancelWarning: Bool {
        return hasChanges(ignore: ["updatedTimestamp", "localUpdateTimestamp"])
    }
    
    /// we need to check if the signature of the user is signed, if yes inform the user that
    /// a change will remove the signature from invoice,
    public var willResetSignature: Bool {
        if hasChanges(ignore: ["updatedTimestamp", "localUpdateTimestamp", "payments"]) && isSigned {
            logger.error("Tell the user that he will delete his recipients.")
            return true
        }
        return false
    }
    
    
    /// This method will check if the job has changes, if you want fields to ignore add them as parameter.
    ///
    /// - Parameter ignore: an array string key to ignore
    /// - Returns: a Boolean
    public func hasChanges(ignore: [String]) -> Bool {
        let all = managedObjectContext?.updatedObjects ?? []
        return all.reduce(false) { (current, object) -> Bool in
            let changes = object.changedValues().filter({ (args) -> Bool in
                let (key, _) = args
                return ignore.contains(key) == false
            })
            return current || changes.count > 0
        }
    }
    
    /// This method will set the job state and also will delete the recipients if needed.
    /// All old recipients objects will be deleted. The recipient is only preserved if
    /// it is present in the send to array.
    ///
    /// - Parameter sendTo: the mails that will be resend, no need for an deletion.
    public func markAsSend(_ sendTo: [String] = []) {
        guard let context = managedObjectContext else {
            return
        }
        
        let recipients = recipientsTyped.filter({ (recipient) -> Bool in
            if let to = recipient.to {
                return !sendTo.contains(to) // negate
            }
            return true
        })
        if recipients.count > 0 {
            _ = RecipientRequest.delete(recipients).subscribe(onNext: { (_) in
                logger.verbose("Did delete all the recipients")
            })
            for recipient in recipients {
                context.delete(recipient)
            }
        }
        
        sentTimestamp = Date()
        state = JobState.sent.rawValue
        try? context.save()
    }
}
