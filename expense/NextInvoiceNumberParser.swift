//
//  NextInvoiceNumberParser.swift
//  InVoice
//
//  Created by Georg Kitz on 16/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import Horreum
import CoreData
import CoreDataExtensio

/// NextNumberParser
@available(*, deprecated, message: "We moved to online generation if IDs")
struct NextRunningNumberParser {
    
    /// Returns the next valid id based on the last offer in the system, if there is none, a default id is returned
    ///
    /// - Returns: the next id or a default id
    static func nextOfferId() -> String {
        return nextId(for: Offer.self) ?? R.string.localizable.est() + "00001"
    }
    
    /// Returns the next valid id based on the last offer in the system, if there is none, a default id is returned
    ///
    /// - Returns: the next id or a default id
    static func nextInvoiceId() -> String {
        return nextId(for: Invoice.self) ?? R.string.localizable.inv() + "00001"
    }
    
    /// Returns the next valid id based on the type given as parameter, if there is none nil is returned.
    ///
    /// - Parameter type: a Offer or Invoice type
    /// - Returns: the next id or nil
    static func nextId<T: Fetchable & Job>(for type: T.Type) -> String? {
        let worker = Horreum.instance!.workerContext()
        let sort = NSSortDescriptor(key: "createdTimestamp", ascending: false)
        let predicate = NSPredicate.noTestData()
        if let job = type.allObjects(matchingPredicate: predicate, sorted: [sort], fetchLimit: 1, context: worker).last as? Job,
           let lastId = job.number {
            return checkNextId(lastId, type: type, context: worker)
        }
        return nil
    }
    
    /// This method checks the given id. In the case the the id already exists the function will iterate over
    /// the numbers until a free slot is found.
    ///
    /// - Parameters:
    ///   - lastJobID: The last used jobID
    ///   - context: the context to search on.
    /// - Returns: the next jobID
    static func checkNextId<T: Fetchable>(_ lastJobID: String, type: T.Type, context: NSManagedObjectContext) -> String {
        var jobID: String = lastJobID
        var notFound: Bool = true
        while notFound { // iterate over until a unused jobid is found.
            jobID = nextId(for: jobID)
            let predicate = NSPredicate.noTestData().and(NSPredicate(format: "number = %@", jobID))
            notFound = type.allObjectsCount(matchingPredicate: predicate, context: context) != 0
        }
        return jobID
    }

    /// Gets the next id from our validator based on the current id
    ///
    /// - Parameter currentId: the latest id in the system
    /// - Returns: the next valid id in the system
    static func nextId(for currentId: String) -> String {
        return IDValidator.autoIncrement(currentId)
    }
}

/// ID Validator
@available(*, deprecated, message: "We moved to online generation if IDs")
struct IDValidator {
    
    /// takes a given `id` and checks if it follows our id syntax <somestring><someint>
    ///
    /// - Parameter stringId: the id to check
    /// - Returns: true if valid otherwise false
    static func isValid(id stringId: String) -> Bool {
        return match(string: stringId).valid
    }
    
    /// Takes a given id and autoincrements it A002 = A00003 afterwards
    ///
    /// - Parameter stringId: the id we want to autoincrement
    /// - Returns: returns the new id
    static func autoIncrement(_ stringId: String) -> String {
        return idFrom(stringId)
    }
    
    /// Reformats a given id to match our syntax <somtext><5digits-with-leading-zeros>
    ///
    /// - Parameter stringId: the id we want to autoincrement
    /// - Returns: returns the new id
    static func reformatId(_ stringId: String) -> String {
        return idFrom(stringId, shouldAutoIncrementId: false)
    }
    
    /// Takes a given id, splits it in prefix + number and returns it in our format
    ///
    /// - Parameters:
    ///   - stringId: the id we want to check
    ///   - shouldAutoIncrementId: if we should +1 the id
    /// - Returns: the formatted or incremented id
    private static func idFrom(_ stringId: String, shouldAutoIncrementId: Bool = true) -> String {
        guard let result = match(string: stringId).result else {
            return ""
        }
        
        let prefixRange = result.range(at: 1)
        let prefix = String(stringId[prefixRange.location..<prefixRange.length])
        
        let idRange = result.range(at: 2)
        var intId = Int(String(stringId[idRange.location..<idRange.location + idRange.length]))!
        intId = shouldAutoIncrementId ? intId + 1 : intId
        
        return String(format: "%@%05d", prefix, intId)
    }
    
    /// Checks if the given string matches our id creteria
    ///
    /// - Parameter string: the id we were given
    /// - Returns: first part determines if the id is valid, second part determins the result we got
    private static func match(string: String) -> (valid: Bool, result: NSTextCheckingResult?) {
        guard let regex = try? NSRegularExpression(pattern: "^([A-Z]+)([0-9]*)$", options: .anchorsMatchLines) else {
            return (false, nil)
        }
        let matches = regex.matches(in: string, options: .anchored, range: NSRange(location: 0, length: string.count))
        guard let firstMatch = matches.first, matches.count == 1 && firstMatch.numberOfRanges == 3 else {
            return (false, nil)
        }
        
        guard firstMatch.range(at: 1).length != 0 && firstMatch.range(at: 2).length != 0 else {
            return (false, nil)
        }
        
        return (true, firstMatch)
    }
}
