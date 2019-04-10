//
//  JobLocalization+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 17.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio

extension JobLocalization: Fetchable, Createable {
    public typealias CreatedType = JobLocalization
    public typealias FetchableType = JobLocalization
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func create(in context: NSManagedObjectContext) -> JobLocalization {
        let localization = JobLocalization(inContext: context)
        
        localization.uuid = UUID().uuidString.lowercased()
        localization.createdTimestamp = Date()
        localization.updatedTimestamp = Date()
        localization.localUpdateTimestamp = Date()
        
        return localization
    }
    
    public static func localization(for language: String?, in context: NSManagedObjectContext) -> JobLocalization? {
        guard let language = language else { return nil }
        let predicate = NSPredicate(format: "language = %@", language)
        return JobLocalization.allObjects(matchingPredicate: predicate, context: context).first
    }
    
    public static func localization(for language: Language, in context: NSManagedObjectContext) -> JobLocalization? {
        return localization(for: language.rawValue, in: context)
    }
}
