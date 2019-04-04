//
//  DefaultData.swift
//  InVoice
//
//  Created by Georg Kitz on 12/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import SwiftMoment

extension String {
    var sampleHintReplaced: String {
        guard let regex = try? NSRegularExpression(pattern: "\\s\\(.*\\)", options: []), UITestHelper.isUITesting else {
            return self
        }
        let mutableSelf = NSMutableString(string: self);
        regex.replaceMatches(in: mutableSelf, options: [], range: NSMakeRange(0, self.count), withTemplate: "")
        return mutableSelf as String
    }
    
    var asSampleEmailAddress: String {
        return self.sampleHintReplaced.lowercased().replacingOccurrences(of: " ", with: ".").appending("@invoicebot.io")
    }
}

// swiftlint:disable type_body_length
struct DefaultData {
    static let TestRemoteID: Int64 = -1  // should not be uploaded

    // swiftlint:disable line_length
    // swiftlint:disable function_body_length
    static func insertDebugData(in context: NSManagedObjectContext) {
        #if !IS_EXTENSION
        DefaultData.insertClientSampleData(in: context)
        DefaultData.insertInvoiceSampleData(in: context)

        if Account.allObjectsCount(context: context) != 0 {
            return
        }
        
        let localizedClient = Client(inContext: context)
        localizedClient.name = R.string.localizable.clientName()
        localizedClient.remoteId = TestRemoteID
        localizedClient.address = R.string.localizable.clientAddress()
        localizedClient.email = R.string.localizable.clientEmail()
        localizedClient.phone = R.string.localizable.clientPhone()
        localizedClient.uuid = UUID().uuidString
        localizedClient.isActive = true
        localizedClient.localUpdateTimestamp = Date()
        localizedClient.createdTimestamp = Date()
        localizedClient.updatedTimestamp = Date()
        
        let localizedItem = Item(inContext: context)
        localizedItem.remoteId = TestRemoteID
        localizedItem.localUpdateTimestamp = Date()
        localizedItem.createdTimestamp = moment().date
        localizedItem.updatedTimestamp = moment().date
        localizedItem.itemDescription =  R.string.localizable.itemDescription()
        localizedItem.price = NSDecimalNumber(value: 120)
        localizedItem.tax = NSDecimalNumber(value: 20)
        localizedItem.uuid = UUID().uuidString
        
        let account = Account.create(in: context)
        account.name = "meisterwork GmbH"
        account.address = "Luegerstraße 10\n9020 Klagenfurt\nAUSTRIA"
        account.email = "info@meisterwork.at"
        account.phone = "+436603830196"
        account.website = "www.meisterwork.at"
        account.taxId = "ATU9231242"
        account.color = "#F0AF52FF"
        account.template = "clean"
        account.logoFileName = "logo"
        account.country = "AT"
        
        let client = Client(inContext: context)
        client.name = "Georg Kitz"
        client.remoteId = TestRemoteID
        client.address = "Johann Offner Str. 17\n9400 Klagenfurt"
        client.email = "georgkitz@gmail.com"
        client.phone = "+436603830196"
        client.uuid = "c_uuid"
        client.isActive = true
        client.localUpdateTimestamp = Date()
        client.createdTimestamp = Date()
        client.updatedTimestamp = Date()
        
        DefaultData.insertInvoiceBotDefaultData(in: context)
        
        let offer = Offer(inContext: context)
        offer.remoteId = TestRemoteID
        offer.uuid = "o_uuid"
        offer.number = R.string.localizable.est() + "00002"
        offer.localUpdateTimestamp = Date()
        offer.createdTimestamp = Date()
        offer.updatedTimestamp = Date()
        offer.total = NSDecimalNumber(value: 1250.50)
        offer.clientName = "Georg Kitz"
        offer.clientAddress = "Johann Offner Str. 17\n9400 Klagenfurt"
        offer.clientEmail = "georgkitz@gmail.com"
        offer.clientPhone = "+436603830196"
        
        offer.client = client
        
        let invoice = Invoice(inContext: context)
        invoice.remoteId = TestRemoteID
        invoice.uuid = "i_uuid"
        invoice.number = R.string.localizable.inv() + "00012"
        invoice.localUpdateTimestamp = Date()
        invoice.createdTimestamp = Date()
        invoice.updatedTimestamp = Date()
        invoice.date = Date()
        invoice.dueTimestamp = moment().add(7, TimeUnit.Days).date
        invoice.total = NSDecimalNumber(value: 990)
        invoice.discount = NSDecimalNumber.zero
        invoice.isDiscountAbsolute = true
        invoice.clientName = "Georg Kitz"
        invoice.clientAddress = "Johann Offner Str. 17\n9400 Klagenfurt"
        invoice.clientEmail = "georgkitz@gmail.com"
        invoice.clientPhone = "+436603830196"
        
        invoice.client = client
        
        let paidInvoice = Invoice(inContext: context)
        paidInvoice.remoteId = TestRemoteID
        paidInvoice.uuid = "ip_uuid"
        paidInvoice.number = R.string.localizable.inv() + "00014"
        paidInvoice.createdTimestamp = moment().subtract(7, TimeUnit.Days).subtract(1, TimeUnit.Months).date
        paidInvoice.localUpdateTimestamp = Date()
        paidInvoice.updatedTimestamp = Date()
        paidInvoice.dueTimestamp = Date()
        paidInvoice.paidTimestamp = moment().subtract(1, TimeUnit.Days).subtract(1, TimeUnit.Months).date
        paidInvoice.total = NSDecimalNumber(value: 1250.50)
        paidInvoice.clientName = "Georg Kitz"
        paidInvoice.clientAddress = "Johann Offner Str. 17\n9400 Klagenfurt"
        paidInvoice.clientEmail = "georgkitz@gmail.com"
        paidInvoice.clientPhone = "+436603830196"
        
        paidInvoice.client = client
        
        let item = Item(inContext: context)
        item.remoteId = TestRemoteID
        item.localUpdateTimestamp = Date()
        item.createdTimestamp = moment().date
        item.updatedTimestamp = moment().date
        item.itemDescription = "iOS Development"
        item.price = NSDecimalNumber(value: 120)
        item.tax = NSDecimalNumber(value: 20)
        
        let item2 = Item(inContext: context)
        item2.remoteId = TestRemoteID
        item2.localUpdateTimestamp = Date()
        item2.createdTimestamp = moment().date
        item2.updatedTimestamp = moment().date
        item2.itemDescription = "Design Work"
        item2.price = NSDecimalNumber(value: 150)
        item2.tax = NSDecimalNumber(value: 10)
        
        let date = Date()
        Array(0...5).forEach { (_) in
            let order = Order(inContext: context)
            order.remoteId = TestRemoteID
            order.createdTimestamp = date
            order.updatedTimestamp = date
            order.localUpdateTimestamp = date
            order.uuid = UUID().uuidString.lowercased()
            order.discount = NSDecimalNumber.zero
            order.quantity = NSDecimalNumber(value: 1)
            order.price = item2.price
            order.tax = item2.tax
            order.itemDescription = item2.itemDescription
            order.item = invoice
            order.template = item2
            order.calculateTotal()
        }
        
        let attachment = Attachment(inContext: context)
        attachment.remoteId = TestRemoteID
        attachment.localUpdateTimestamp = Date()
        attachment.createdTimestamp = Date()
        attachment.updatedTimestamp = Date()
        attachment.fileName = "Attachement Dec 6, 2017"
        attachment.uuid = "92953B8B-BEBB-4B39-934D-44349F51869F"
        attachment.path = "/Users/georgkitz/Library/Developer/CoreSimulator/Devices/2F7C9E8B-F164-4944-946E-FD755416E643/data/Containers/Data/Application/8A705D81-887D-44DC-8326-F88FF8DFEB16/Documents/image-attachements/92953B8B"
        attachment.thumbPath = "/Users/georgkitz/Library/Developer/CoreSimulator/Devices/2F7C9E8B-F164-4944-946E-FD755416E643/data/Containers/Data/Application/8A705D81-887D-44DC-8326-F88FF8DFEB16/Documents/image-attachements/92953B8B"
        attachment.job = invoice
        do {
            try context.save()
        } catch {
            logger.error("Failed to insert test data")
        }
        #endif
    }
    
    static func insertReleaseData(in context: NSManagedObjectContext, createAccountIfNeeded: Bool = true) {

        if createAccountIfNeeded {
            if Account.allObjectsCount(context: context) != 0 {
                return
            }
            _ = Account.create(in: context)
            try? context.save()
        }
        
        return
        #if !IS_EXTENSION
        let uuid = "1e093bdf-a372-4cde-b37a-2e430732591e"
        let client = Client(inContext: context)
        client.name = R.string.localizable.clientName().sampleHintReplaced
        client.remoteId = UITestHelper.isUITesting ? 100 : TestRemoteID
        client.address = R.string.localizable.clientAddress()
        client.email = R.string.localizable.clientName().asSampleEmailAddress
        client.phone = R.string.localizable.clientPhone()
        client.uuid = uuid
        client.isActive = true
        client.localUpdateTimestamp = Date()
        client.createdTimestamp = Date()
        client.updatedTimestamp = Date()
        
        let offer = Offer(inContext: context)
        offer.remoteId = UITestHelper.isUITesting ? 100 : TestRemoteID
        offer.uuid = uuid
        offer.number = R.string.localizable.est() + "00000"
        offer.localUpdateTimestamp = Date()
        offer.createdTimestamp = Date()
        offer.updatedTimestamp = Date()
        offer.date = Date()
        offer.clientName = R.string.localizable.clientName().sampleHintReplaced
        offer.clientAddress = R.string.localizable.clientAddress()
        offer.clientEmail = R.string.localizable.clientName().asSampleEmailAddress
        offer.clientPhone = R.string.localizable.clientPhone()
        offer.client = client
        
        let invoice = Invoice(inContext: context)
        invoice.remoteId = UITestHelper.isUITesting ? 100 : TestRemoteID
        invoice.uuid = uuid
        invoice.number = R.string.localizable.inv() + "00000"
        invoice.localUpdateTimestamp = Date()
        invoice.createdTimestamp = Date()
        invoice.updatedTimestamp = Date()
        invoice.date = Date()
        invoice.dueTimestamp = moment().add(7, TimeUnit.Days).date
        invoice.discount = NSDecimalNumber(value: 20)
        invoice.isDiscountAbsolute = true
        invoice.clientName = R.string.localizable.clientName()
        invoice.clientAddress = R.string.localizable.clientAddress()
        invoice.clientEmail = R.string.localizable.clientEmail()
        invoice.clientPhone = R.string.localizable.clientPhone()
        invoice.paymentDetails = R.string.localizable.sampleBankDetails()
        invoice.client = client
        
        let orders: [(String, NSDecimalNumber, NSDecimalNumber, NSDecimalNumber)] = [
            (R.string.localizable.itemDescription().sampleHintReplaced, NSDecimalNumber(value: 2), NSDecimalNumber(value: 120), NSDecimalNumber.zero),
            (R.string.localizable.itemDescription1().sampleHintReplaced, NSDecimalNumber(value: 4), NSDecimalNumber(value: 220), NSDecimalNumber(value: 20)),
            (R.string.localizable.itemDescription2().sampleHintReplaced, NSDecimalNumber(value: 6), NSDecimalNumber(value: 220), NSDecimalNumber.zero)
        ]
        
        let date = Date()
        orders.enumerated().forEach { (value) in
            let orderContent = value.element
            
            let item = Item(inContext: context)
            item.remoteId = UITestHelper.isUITesting ? 100 : TestRemoteID
            item.localUpdateTimestamp = Date()
            item.createdTimestamp = moment().date
            item.updatedTimestamp = moment().date
            item.itemDescription =  orderContent.0
            item.price = NSDecimalNumber(value: 120)
            item.tax = NSDecimalNumber(value: 20)
            item.uuid = uuid
            
            if value.offset == 0 {
                return
            }
            
            let order = Order(inContext: context)
            order.remoteId = UITestHelper.isUITesting ? 100 : TestRemoteID
            order.createdTimestamp = date
            order.updatedTimestamp = date
            order.localUpdateTimestamp = date
            order.uuid = uuid
            order.discount = orderContent.3
            order.isDiscountAbsolute = true
            order.quantity = orderContent.1
            order.price = orderContent.2
            order.tax = item.tax
            order.itemDescription = orderContent.0
            order.item = invoice
            order.template = item
            order.calculateTotal()
        }
        
        let item = Item.allObjects(context: context)[0]
        let offerOrder = Order(inContext: context)
        offerOrder.remoteId = UITestHelper.isUITesting ? 100 : TestRemoteID
        offerOrder.createdTimestamp = date
        offerOrder.updatedTimestamp = date
        offerOrder.localUpdateTimestamp = date
        offerOrder.uuid = "514eeebf-7909-4ea0-a02d-801aa45798b1"
        offerOrder.discount = NSDecimalNumber.zero
        offerOrder.quantity = NSDecimalNumber(value: 5)
        offerOrder.price = item.price
        offerOrder.tax = item.tax
        offerOrder.itemDescription = item.itemDescription
        offerOrder.item = offer
        offerOrder.template = item
        offerOrder.calculateTotal()
        
        invoice.total = BalanceModel.balance(for: invoice).total
        offer.total = BalanceModel.balance(for: offer).total
        
        do {
            try context.save()
        } catch {
            logger.error("Failed to insert release data")
        }
        #endif
    }

    static func insertDefaultData(in context: NSManagedObjectContext, debug: Bool = false) {
        if debug {
            insertDebugData(in: context)
            insertReleaseData(in: context, createAccountIfNeeded: false)
        } else {
            insertReleaseData(in: context)
        }
    }
    
    // swiftlint:enable function_body_length
    // swiftlint:enable line_length

    static func insertInvoiceBotDefaultData(in context: NSManagedObjectContext) {
        // added the for the invoice voice bot testing
        if UITestHelper.isUITesting {
            return 
        }
        let client = Client(inContext: context)
        client.remoteId = TestRemoteID
        client.name = "Richard Marktl"
        client.address = "Luegerstrasse 10, 9020 Klagenfurt"
        client.email = "richard.marktl@gmail.com"
        client.phone = "+436504206311"
        client.uuid = "c_uuid2"
        client.isActive = true
        client.localUpdateTimestamp = Date()
        client.createdTimestamp = Date()
        client.updatedTimestamp = Date()
        
        let client2 = Client(inContext: context)
        client2.remoteId = TestRemoteID
        client2.name = "Richard Mayer"
        client2.address = "Obere Fellacher Strasse 17, 9500 Villach"
        client2.email = "richard.mayer@gmail.com"
        client2.phone = "+436504206312"
        client2.uuid = "c_uuid3"
        client2.isActive = true
        client2.localUpdateTimestamp = Date()
        client2.createdTimestamp = Date()
        client2.updatedTimestamp = Date()
        
        let item = Item(inContext: context)
        item.remoteId = TestRemoteID
        item.localUpdateTimestamp = moment().date
        item.createdTimestamp = moment().date
        item.updatedTimestamp = moment().date
        item.itemDescription = "Techniker Stunde"
        item.price = NSDecimalNumber(value: 120)
        item.tax = NSDecimalNumber(value: 20)
        
        let item2 = Item(inContext: context)
        item2.remoteId = TestRemoteID
        item2.localUpdateTimestamp = moment().date
        item2.createdTimestamp = moment().date
        item2.updatedTimestamp = moment().date
        item2.itemDescription = "Montage Stunde"
        item2.price = NSDecimalNumber(value: 20)
        item2.tax = NSDecimalNumber(value: 20)
    }
    
    @discardableResult static func insertClientSampleData(in context: NSManagedObjectContext) -> [Client] {
        
        guard let data = stubbedResponse("insert_sample_clients") else {
            return []
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return []
        }
        return updateObjectsFromJSONIngorePagination(context)(json)
    }
    
    @discardableResult static func insertInvoiceSampleData(in context: NSManagedObjectContext) -> [Invoice] {
        
        guard let data = stubbedResponse("insert_sample_invoice_paid_data") else {
            return []
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []), let root = json as? JSONDictionary, let results = root["results"] as? [JSONDictionary] else {
            return []
        }
        
        var invoiceId = "INV2018001"
        let invoices = updateObjectsFromJSONIngorePagination(context)(json) as [Invoice]
        invoices.enumerated().forEach { (item) in
            
            invoiceId = NextRunningNumberParser.nextId(for: invoiceId)
            item.element.number = invoiceId
            
            if item.element.client == nil {
                guard let idString = results[item.offset]["client"] as? String, let remoteId = Int64(idString) else {
                    return
                }
                item.element.client = Client.object(withRemoteId: remoteId, in: context)
            }
            item.element.update(from: item.element.client)
        }
        return invoices
    }
}
// swiftlint:enable type_body_length
