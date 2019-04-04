//
//  CoreDataMappable+Helper.swift
//  InVoice
//
//  Created by Georg Kitz on 18/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio

struct PagedResult<T: BaseItem> {
    let results: [T]
    let nextPageCursor: String?
}

func updateObjectWithJSON<T: BaseItem>(_ object: T, considerLocalModifiedTimestamp: Bool = false) -> (Any) -> T {
    
    return { JSON -> T in
        
        guard let JSON = JSON as? JSONDictionary else {
            return object
        }
        
        //this will consider the local timestamp and return the object if it doesn't fit
        if considerLocalModifiedTimestamp {
            
            if let updatedValue = JSON["updated"] as? String, let updatedTimestamp = StringToISO8601DateTransfomer().typedTransformedValue(updatedValue),
                let timestamp = object.localUpdateTimestamp, updatedTimestamp.timeIntervalSince1970 < timestamp.timeIntervalSince1970 {
                return object
            }
        }
        
        //this will not update the object if the local copy has the same updated timestamp
        if let updatedValue = JSON["updated"] as? String, let updatedTimestamp = StringToISO8601DateTransfomer().typedTransformedValue(updatedValue),
            let timestamp = object.localUpdateTimestamp, timestamp.timeIntervalSince1970 == updatedTimestamp.timeIntervalSince1970 {
            return object
        }
        
        object.updateFromJSON(JSON, context: object.managedObjectContext!)
        return object
    }
}

func updateRemoteItemWithJSON<T: BaseItem & Fetchable>(_ remoteId: Int64, in context: NSManagedObjectContext, considerLocalModifiedTimestamp: Bool = false,
                                                       manualUpdateBlock: ((T, JSONDictionary) -> T)? = nil) -> (Any) -> T {
    return { JSON -> T in

        let loadedItem: T
        if let item = T.object(withRemoteId: remoteId, in: context) as? T {
            loadedItem = item
        } else {
            loadedItem = T.insertEntity(entityDescription: T.entityDescription(context), context: context)
            loadedItem.remoteId = remoteId
        }
        
        let object = updateObjectWithJSON(loadedItem)(JSON)
        if let updateBlock = manualUpdateBlock, let JSON = JSON as? JSONDictionary {
            return updateBlock(object, JSON)
        }
        
        return object
    }
}

func updateObjectsFromJSON<T: BaseItem>(_ context: NSManagedObjectContext, considerLocalModifiedTimestamp: Bool = false,
                                        manualUpdateBlock: ((T, JSONDictionary) -> T)? = nil) -> (Any) -> PagedResult<T> {
    
    return { JSON -> PagedResult<T> in
        
        guard let JSON = JSON as? JSONDictionary else {
            return PagedResult(results: [], nextPageCursor: nil)
        }
        
        guard let results = JSON["results"] as? [JSONDictionary] else {
            return PagedResult(results: [], nextPageCursor: nil)
        }
        
        let result = results.map { (entityJSON) -> T? in
            
            if let value = entityJSON["uuid"] {
                
                let entity = T.loadOrInsertEntity("uuid", value: value, context: context)
                if considerLocalModifiedTimestamp {
                    
                    if let updatedValue = entityJSON["updated"] as? String, let updatedTimestamp = StringToISO8601DateTransfomer().typedTransformedValue(updatedValue),
                        let timestamp = entity.localUpdateTimestamp, updatedTimestamp.timeIntervalSince1970 < timestamp.timeIntervalSince1970 {
                        return entity
                    }
                }
                
                entity.updateFromJSON(entityJSON, context: context)
                
                if let updateBlock = manualUpdateBlock {
                    return updateBlock(entity, entityJSON)
                }
                
                return entity
            }
            
            return nil
            }
            .filter { return $0 != nil }
            .map { return $0! }
        
        let cursor = extractNextPageFromJSON(JSON)
        return PagedResult(results: result, nextPageCursor: cursor)
    }
}

func updateObjectsFromJSONIngorePagination<T: BaseItem>(_ context: NSManagedObjectContext, considerLocalModifiedTimestamp: Bool = false) -> (Any) -> [T] {
    return { JSON -> [T] in
        return updateObjectsFromJSON(context, considerLocalModifiedTimestamp: considerLocalModifiedTimestamp)(JSON).results
    }
}

func extractNextPageFromJSON(_ JSON: JSONDictionary) -> String? {
    
    guard let nextPageURLString = JSON["next"] as? String else {
        return nil
    }
    
    guard let components = URLComponents(string: nextPageURLString), let queryItems = components.queryItems else {
        return nil
    }
    
    guard let value = queryItems.filter({ $0.name == "cursor" }).first?.value else {
        return nil
    }
    
    return value
}

public func createObjectWithJSON<T: NSManagedObject>(_ context: NSManagedObjectContext) -> (Any) throws -> T {
    
    return { JSON -> T in
        
        guard let JSON  = JSON as? JSONDictionary else {
            throw ApiError.invalidJSON
        }
        
        let object = T(entity: T.entityDescription(context), insertInto: context)
        object.updateFromJSON(JSON, context: context)
        
        return object
    }
}
