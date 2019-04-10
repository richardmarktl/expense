//
//  FileManagerHelper.swift
//  InVoice
//
//  Created by Georg Kitz on 05/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

public enum FileManagerError: Error {
    case noSuchFile(String)
    case cannotCreateDirectory(Directory)
}

public struct FileManagerHelper {
    public static func createDirectory(_ directory: Directory, in searchPath: FileManager.SearchPathDirectory = .documentDirectory) -> String? {
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(searchPath, .userDomainMask, true)[0] + "/" + directory.name + "/"
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
    
    public static func deleteFile(at path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
    }
    
    public static func copyFile(at sourcePath: String, to directory: Directory, in searchPath: FileManager.SearchPathDirectory = .documentDirectory,  with filename: String) throws -> String {
        let fileManager = FileManager()
        if !fileManager.fileExists(atPath: sourcePath) {
            throw FileManagerError.noSuchFile(sourcePath)
        }
        
        guard let directoryPath = createDirectory(directory, in: searchPath) else {
            throw FileManagerError.cannotCreateDirectory(directory)
        }
        
        let destFilePath = directoryPath + filename
        if fileManager.fileExists(atPath: destFilePath) {
            try fileManager.removeItem(atPath: destFilePath)
        }
        
        try fileManager.copyItem(atPath: sourcePath, toPath: destFilePath)
        return destFilePath
    }
}
