//
//  FileManagerHelper.swift
//  InVoice
//
//  Created by Georg Kitz on 05/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

enum Directory: String {
    case invoices
    case shared
    case export
    case imageAttachments = "image-attachements"
}

struct FileManagerHelper {
    static func createDirectory(_ directory: Directory, in searchPath: FileManager.SearchPathDirectory = .documentDirectory) -> String? {
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(searchPath, .userDomainMask, true)[0] + "/" + directory.rawValue + "/"
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                return path
            } catch {
                print("\(error)")
                return nil
            }
        }
        return path
    }
    
    static func deleteFile(at path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
    }
    
    static func copyFile(at sourcePath: String, to directory: Directory, in searchPath: FileManager.SearchPathDirectory = .documentDirectory,  with filename: String) throws -> String {
        let fileManager = FileManager()
        if !fileManager.fileExists(atPath: sourcePath) {
            throw "No Source File"
        }
        
        guard let directoryPath = createDirectory(directory, in: searchPath) else {
            throw "Can't create directory"
        }
        
        let destFilePath = directoryPath + filename
        if fileManager.fileExists(atPath: destFilePath) {
            try fileManager.removeItem(atPath: destFilePath)
        }
        
        try fileManager.copyItem(atPath: sourcePath, toPath: destFilePath)
        return destFilePath
    }
}
