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
import InvoiceBotSDK

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
        let frameworkBundle = Bundle(for: BudgetWallet.self) // Bundle(forClass: BudgetWallet.self)
        guard let url = frameworkBundle.url(forResource: "invoice", withExtension: "momd") else {
            fatalError("No invoice.momd found.")
        }
        return url
//        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("InvoiceBotSDK.bundle")
//        let resourceBundle = Bundle(url: bundleURL!)
//        // let image = UIImage(named: "ic_arrow_back", inBundle: resourceBundle, compatibleWithTraitCollection: nil)
//        // print(image)
//
//        return Bundle.main.url(forResource: "invoice", withExtension: "momd")!
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
