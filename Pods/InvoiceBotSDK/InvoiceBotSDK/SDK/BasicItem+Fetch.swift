//
//  BasicItem+Fetch.swift
//  InVoice
//
//  Created by Georg Kitz on 26/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio

public extension Fetchable {
    static func object(withRemoteId remoteId: Int64, in context: NSManagedObjectContext) -> Self.FetchableType? {
        let predicate = NSPredicate(format: "remoteId = %d", remoteId)
        return allObjects(matchingPredicate: predicate, sorted: nil, fetchLimit: 1, context: context).first
    }
    
    static func object(withUuid uuid: String, in context: NSManagedObjectContext) -> Self.FetchableType? {
        let predicate = NSPredicate(format: "uuid = %@", uuid)
        return allObjects(matchingPredicate: predicate, sorted: nil, fetchLimit: 1, context: context).first
    }
    
    static func notUploaded(in context: NSManagedObjectContext) -> [Self.FetchableType] {
        let predicate = NSPredicate(
            format: "remoteId != %d AND (remoteId = 0 OR localUpdateTimestamp > updatedTimestamp)",
            DefaultData.TestRemoteID
        )
        return allObjects(matchingPredicate: predicate, sorted: nil, fetchLimit: nil, context: context)
    }
}
