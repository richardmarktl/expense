//
//  Attachment+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 26/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio

extension Attachment: Fetchable {
    
    public typealias FetchableType = Attachment
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    func update(from storageItem: ImageStorageItem) {
        uuid = storageItem.filename
        path = storageItem.imagePath
        thumbPath = storageItem.thumbnailPath
    }
    
    static func create(in context: NSManagedObjectContext) -> Attachment {
        let attachment = Attachment(inContext: context)
        attachment.createdTimestamp = Date()
        attachment.updatedTimestamp = Date()
        attachment.localUpdateTimestamp = Date()
        return attachment
    }
    
    static func create(from attachment: Attachment, in context: NSManagedObjectContext) -> Attachment {
        let newAttachment = Attachment.create(in: context)
        
        let filename = NSUUID().uuidString.lowercased()
        newAttachment.uuid = filename
        newAttachment.fileName = attachment.fileName
        newAttachment.sort = attachment.sort
        
        if let oldFilename = attachment.uuid {
            let paths = ImageStorage.duplicate(for: oldFilename, newFilename: filename)
            newAttachment.path = paths.0
            newAttachment.thumbPath = paths.1
        }
        return newAttachment
    }
}
