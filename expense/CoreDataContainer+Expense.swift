//
//  CoreDataContainer+Expense.swift
//  InVoice
//
//  Created by Georg Kitz on 10/04/2018.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import CoreData
import CoreDataExtensio
import Crashlytics

extension CoreDataContainer {
    
    private static let fileName = "invoice.sqlite"
    
    class func createDatabaseForApp() {
        createDatabaseWithStoreType(NSSQLiteStoreType)
    }
    
    class func creatDatabaseForTesting() {
        createDatabaseWithStoreType(NSInMemoryStoreType)
    }
    
    fileprivate class func createDatabaseWithStoreType(_ storeType: String) {
        guard let containerStoreUrl = containerStoreURL() else {
            return
        }
        
        let description = NSPersistentStoreDescription(url: containerStoreUrl)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        description.type = storeType
        
        CoreDataContainer.create(
            name: CoreDataContainer.fileName,
            modelURL: modelURL(),
            description: description,
            completionHandler: { (desc, error) in 
            if let error = error {
                print("failed to load the core data store \(error)")
            }
        })
    }
    
    fileprivate class func modelURL() -> URL {
        return Bundle.main.url(forResource: "invoice", withExtension: "momd")!
    }
    
    fileprivate class func containerStoreURL() -> URL? {
        guard let appGroup = Bundle.main.infoDictionary?["APP_GROUP"] as? String else {
            return nil
        }
        return FileManager().containerURL(forSecurityApplicationGroupIdentifier: appGroup)?.appendingPathComponent(CoreDataContainer.fileName)
    }
}

func directory(_ directory: FileManager.SearchPathDirectory = .documentDirectory) -> URL {
    return FileManager().urls(for: directory, in: .userDomainMask).last!
}
