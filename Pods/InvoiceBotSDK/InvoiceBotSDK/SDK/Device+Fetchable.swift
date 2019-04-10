//
//  Device+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 02/02/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio

extension Device: Fetchable {
    
    public typealias FetchableType = Device
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func create(in context: NSManagedObjectContext) -> Device {
        let device = Device(inContext: context)
        device.uuid = (UIDevice.current.identifierForVendor ?? UUID()).uuidString.lowercased()
        device.createdTimestamp = Date()
        device.updatedTimestamp = Date()
        device.localUpdateTimestamp = Date()
        return device
    }
    
    public static func current(in context: NSManagedObjectContext) -> Device {
        if let device = Device.allObjects(fetchLimit: 1, context: context).first {
            return device
        }
        return Device.create(in: context)
    }
}
