//
//  CoreDataContainer.swift
//  expense
//
//  Created by Richard Marktl on 09.04.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData


/// The CoreDataContainer wraps the handling and creation of the NSPersistentContainer
/// coredata stack. Implemented as Singleton.
public class CoreDataContainer: NSObject {
    
    struct Static {
        static var instance: CoreDataContainer?
    }
    
    public class var instance: CoreDataContainer? {
        get {
            return Static.instance
        }
        set {
            Static.instance = newValue
        }
    }
    
    public class func create(modelURL: URL, storeURL: URL, storeType: String, name: String, options: CoreDataContainerStoreOptions) {
        instance = CoreDataContainer(modelURL: modelURL, storeURL: storeURL, storeType: storeType, name: name, options: options)
    }
    
    public class func destory() throws {
        try instance?.destroy()
        instance = nil
    }
    
    public var mainContext: NSManagedObjectContext { return container.viewContext }
    private let container: NSPersistentContainer
    
    init?(modelURL: URL, storeURL: URL, storeType: String, name: String, options: CoreDataContainerStoreOptions) {
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = storeType
        for (key, value) in options.optionsDictionary() {
            description.setOption(value, forKey: key)
        }
        // let name = storeURL.
        if let model = NSManagedObjectModel(contentsOf: modelURL) {
            container = NSPersistentContainer(name: name, managedObjectModel: model)
            container.viewContext.stalenessInterval = 0
        } else {
            return nil
        }
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveNotification), name:NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func workerContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    public func destroy() throws {
        for description in container.persistentStoreDescriptions {
            if let storeURL = description.url {
                do {
                    try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: description.type, options: description.options)
                    try FileManager().removeItem(at: storeURL)
                } catch {
                    print("Destroy failed with: %s", error)
                }
            }
        }
        CoreDataContainer.instance = nil
    }
    
    @objc func saveNotification(notification: NSNotification) {
        let context  = notification.object as! NSManagedObjectContext?
        if let context = context, context != mainContext {
            
            let persistentStoreCoordinator = context.persistentStoreCoordinator
            if let parent = context.parent, container.persistentStoreCoordinator == persistentStoreCoordinator {
                parent.perform {
                    do {
                        try parent.save()
                    } catch {
                        print("Failed to merge changes with error: \(error)")
                    }
                }
            } else {
                mainContext.perform {
                    self.mainContext.mergeChanges(fromContextDidSave: notification as Notification)
                }
            }
        }
    }
}

public struct CoreDataContainerStoreOptions {
    let migrateAutomatically: Bool
    let inferMappingModelAutomatically: Bool
    
    public init(migrateAutomatically: Bool = true, inferMappingModelAutomatically: Bool = true) {
        self.migrateAutomatically = migrateAutomatically
        self.inferMappingModelAutomatically = inferMappingModelAutomatically
    }
    
    public func optionsDictionary() -> [String: NSObject] {
        return [
            NSMigratePersistentStoresAutomaticallyOption: NSNumber(booleanLiteral: migrateAutomatically),
            NSInferMappingModelAutomaticallyOption: NSNumber(booleanLiteral: inferMappingModelAutomatically),
        ]
    }
}
