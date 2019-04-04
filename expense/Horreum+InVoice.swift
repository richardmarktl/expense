//
//  Horreum+InVoice.swift
//  InVoice
//
//  Created by Georg Kitz on 09/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Horreum
import CoreData
import Crashlytics

extension Horreum {
    
    private static let fileName = "invoice.sqlite"
    
    class func createDatabaseForApp() {
        createDatabaseWithStoreType(NSSQLiteStoreType)
    }
    
    class func creatDatabaseForTesting() {
        createDatabaseWithStoreType(NSInMemoryStoreType)
    }
    
    fileprivate class func createDatabaseWithStoreType(_ storeType: String) {
        guard let containerStoreUrl = containerStoreURL() else { return }
        
        if needsMigration() {
            Horreum.create(modelURL(), storeURL: storeURL(), storeType: storeType, options: HorreumStoreOptions())
            do {
                try Horreum.instance?.migrate(to: containerStoreUrl, type: storeType, options: HorreumStoreOptions())
            } catch {
                print(error)
                logger.error("Failed to migrate CoreData Stores", error.localizedDescription)
                #if !IS_EXTENSION
                Crashlytics.sharedInstance().recordError(error)
                #endif
            }
        } else {
            Horreum.create(modelURL(), storeURL: containerStoreUrl, storeType: storeType, options: HorreumStoreOptions())
        }
    }
    
    fileprivate class func modelURL() -> URL {
        return Bundle.main.url(forResource: "invoice", withExtension: "momd")!
    }
    
    fileprivate class func storeURL() -> URL {
        let dir = directory()
        return dir.appendingPathComponent(Horreum.fileName)
    }
    
    fileprivate class func containerStoreURL() -> URL? {
        let appGroup = Bundle.main.infoDictionary!["APP_GROUP"] as! String
        return FileManager().containerURL(forSecurityApplicationGroupIdentifier: appGroup)?.appendingPathComponent(Horreum.fileName)
    }
    
    func workerContextFromMasterContext() -> NSManagedObjectContext {
        let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ctx.parent = mainContext
        return ctx
    }
    
    fileprivate class func needsMigration() -> Bool {
        guard let containerStoreUrl = containerStoreURL() else { return false}
        let fileManager = FileManager()
        
        if fileManager.fileExists(atPath: storeURL().path) && !fileManager.fileExists(atPath: containerStoreUrl.path){
            return true
        }
        return false
    }
}

func directory(_ directory: FileManager.SearchPathDirectory = .documentDirectory) -> URL {
    return FileManager().urls(for: directory, in: .userDomainMask).last!
}
