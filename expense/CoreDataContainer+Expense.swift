//
//  CoreDataContainer+Expense.swift
//  InVoice
//
//  Created by Georg Kitz on 10/04/2018.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import CoreData
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
        guard let containerStoreUrl = containerStoreURL() else { return }
        CoreDataContainer.create(
            modelURL: modelURL(),
            storeURL: containerStoreUrl,
            storeType: storeType,
            name: CoreDataContainer.fileName,
            options: CoreDataContainerStoreOptions()
        )
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
    
    func workerContextFromMasterContext() -> NSManagedObjectContext {
        let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ctx.parent = mainContext
        return ctx
    }
    
//    fileprivate class func needsMigration() -> Bool {
//        guard let containerStoreUrl = containerStoreURL() else { return false }
//        let fileManager = FileManager()
//
//        if fileManager.fileExists(atPath: storeURL().path) && !fileManager.fileExists(atPath: containerStoreUrl.path){
//            return true
//        }
//        return false
//    }
}

func directory(_ directory: FileManager.SearchPathDirectory = .documentDirectory) -> URL {
    return FileManager().urls(for: directory, in: .userDomainMask).last!
}
