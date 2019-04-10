//
//  Directories.swift
//  InvoiceBotSDK
//
//  Created by Georg Kitz on 09.04.19.
//  Copyright © 2019 Georg Kitz. All rights reserved.
//

import Foundation
import ImageStorage

public enum FileSystemDirectory: String, Directory {
    case invoices
    case shared
    case export
    case imageAttachments = "image-attachements"
    
    public var name: String {
        return self.rawValue
    }
}
