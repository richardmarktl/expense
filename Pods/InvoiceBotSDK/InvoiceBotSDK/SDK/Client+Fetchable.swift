//
//  Client+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 12/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio
import Contacts

public extension CNContact {
    /// This var generates the name of the contact base on the given, family name and
    /// if not available on the organization name.
    var fullName: String {
        if givenName.isEmpty == false || familyName.isEmpty == false {
            if givenName.isEmpty {
                return familyName
            }
            return givenName + " " + familyName
        }
        return organizationName
    }
}

extension Client: Fetchable, Createable {
    
    public typealias CreatedType = Client
    public typealias FetchableType = Client
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public var typedJobs: [Job] {
        return jobs?.allObjects as? [Job] ?? []
    }
    
    public var typedInvoices: [Invoice] {
        return typedJobs.filter { $0 is Invoice } as? [Invoice] ?? []
    }
    
    public var typedOffers: [Offer] {
        return typedJobs.filter { $0 is Offer } as? [Offer] ?? []
    }
    
    public class func fromCNContact(contact: CNContact, in context: NSManagedObjectContext) -> Client {
        let client = Client.create(in: context)
        
        client.name = contact.fullName
        client.phone = contact.phoneNumbers.first?.value.stringValue ?? ""
        client.email = contact.emailAddresses.first?.value as String? ?? ""
        
        if let address = contact.postalAddresses.first?.value {
            client.address = address.street + "\n" + address.postalCode + "\n" + address.city
        }
        
        return client
    }
    
    public class func nameFromCNContact(_ contact: CNContact) -> String {
        if contact.givenName.isEmpty == false || contact.familyName.isEmpty == false {
            if contact.givenName.isEmpty {
                return contact.familyName
            }
            return contact.givenName + " " + contact.familyName
        }
        return contact.organizationName
    }

    public static func create(in context: NSManagedObjectContext) -> Client {
        let client = Client(inContext: context)
        client.uuid = UUID().uuidString.lowercased()
        client.number = client.uuid?.shortenedUUIDString
        client.createdTimestamp = Date()
        client.updatedTimestamp = Date()
        client.localUpdateTimestamp = Date()
        client.isActive = true
        return client
    }
    
    public func update(from job: Job) {
        name = job.clientName
        email = job.clientEmail
        phone = job.clientPhone
        taxId = job.clientTaxId
        address = job.clientAddress
        website = job.clientWebsite
        number = job.clientNumber
    }
}
