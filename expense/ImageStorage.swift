//
//  ImageStorage.swift
//  InVoice
//
//  Created by Georg Kitz on 26/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import ImageIO

struct ImageStorageItem {
    let image: UIImage
    let thumbnail: UIImage
    let imagePath: String
    let thumbnailPath: String
    let filename: String
    
    var imageURL: URL {
        return URL(fileURLWithPath: imagePath)
    }
}

enum ImageType {
    case png
    case jpg(quality: Float)
    
    var identifier: String {
        switch self {
        case .png:
            return "png"
        case .jpg(_):
            return "jpg"
        }
    }
}

enum ImageStorageError: Error {
    case generateThumbnail
    case storeFile
    case loadFile
}

extension String {
    var withJPGFileExtension: String {
        return self + ".jpg"
    }
    
    var removeJPGFileExtension: String {
        return self.replacingOccurrences(of: ".jpg", with: "")
    }
}

struct ImageStorage {
    
    static var cache: [String: ImageStorageItem] = [:]
    
    static func storeImage(originalImage: UIImage, filename: String = UUID().uuidString.lowercased()) -> Observable<ImageStorageItem> {
        return Observable.just(()).observeOn(ConcurrentDispatchQueueScheduler(qos: .background)).flatMap { _ -> Observable<ImageStorageItem> in
            return Observable.create { (observer) -> Disposable in
                
                //create thumbnail
                guard let thumbnail = generateThumbnail(from: originalImage) else {
                    observer.onError(ImageStorageError.generateThumbnail)
                    return Disposables.create()
                }
                
                //store files
                guard let thumbPath = storeImage(image: thumbnail, filename: filename + "_thumbnail"),
                    let path = storeImage(image: originalImage, filename: filename, compression: 0.1) else {
                        observer.onError(ImageStorageError.generateThumbnail)
                        return Disposables.create()
                }
                
                let item = ImageStorageItem(image: originalImage, thumbnail: thumbnail, imagePath: path, thumbnailPath: thumbPath, filename: filename)
                observer.onNext(item)
                observer.onCompleted()
                
                return Disposables.create()
            }.do(onNext: { (storageItem) in
                cache[storageItem.filename] = storageItem
            })
        }
        .observeOn(MainScheduler.instance)
    }
    
    static func deleteImage(for filename: String) {
        
        guard let directory = createDirectory() else {
            return
        }
        
        let path = directory + filename.withJPGFileExtension
        let thumbPath = directory + filename + "_thumbnail".withJPGFileExtension
        try? FileManager.default.removeItem(atPath: path)
        try? FileManager.default.removeItem(atPath: thumbPath)
        
        cache.removeValue(forKey: filename)
    }
    
    static func loadImage(for filename: String) -> Observable<ImageStorageItem> {
        
        if let storageItem = cache[filename] {
            return Observable.just(storageItem)
        }
        
        return Observable.just(()).observeOn(ConcurrentDispatchQueueScheduler(qos: .background)).flatMap { _ -> Observable<ImageStorageItem> in
            
            return Observable.create({ (observer) -> Disposable in
                
                guard let thumbData = loadImageData(for: filename + "_thumbnail"), let data = loadImageData(for: filename) else {
                    observer.onError(ImageStorageError.loadFile)
                    return Disposables.create()
                }
                
                let item = ImageStorageItem(image: data.0, thumbnail: thumbData.0, imagePath: data.1, thumbnailPath: thumbData.1, filename: filename)
                observer.onNext(item)
                return Disposables.create()
                
            }).do(onNext: { (storageItem) in
                cache[storageItem.filename] = storageItem
            })
            
        }.observeOn(MainScheduler.instance)
    }
    
    static func contains(filename: String) -> Bool {
        return cache[filename] != nil
    }
    
    static func loadAlreadyLoadedItem(for filename: String) -> ImageStorageItem? {
        if let storageItem = cache[filename] {
            return storageItem
        }
        return nil
    }
    
    static private func generateThumbnail(from originalImage: UIImage) -> UIImage? {
        guard let imageData = UIImageJPEGRepresentation(originalImage, 0.5) as CFData?,
            let source = CGImageSourceCreateWithData(imageData, nil) else {
                return nil
        }
        
        let options = [
            kCGImageSourceShouldAllowFloat as String: true as NSNumber,
            kCGImageSourceCreateThumbnailWithTransform as String: true as NSNumber,
            kCGImageSourceCreateThumbnailFromImageAlways as String: true as NSNumber,
            kCGImageSourceThumbnailMaxPixelSize as String: 88 as NSNumber
        ]
        
        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: thumbnail)
    }
    
    static private func storeImage(image: UIImage, filename: String, compression: CGFloat = 1.0) -> String? {
        
        guard let directory = createDirectory() else {
            return nil
        }
        
        let data = UIImageJPEGRepresentation(image, compression)
        let path = directory + filename.withJPGFileExtension
        FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        
        return path
    }
    
    static private func loadImageData(for filename: String) -> (UIImage, String)? {
        
        guard let directory = createDirectory() else {
            return nil
        }
        
        let path = directory + filename.withJPGFileExtension
        guard let image = UIImage(contentsOfFile: path) else {
            return nil
        }
        return (image, path)
    }
    
    static func duplicate(for filename: String, newFilename: String) -> (String, String) {
        guard let directory = createDirectory() else {
            return ("", "")
        }
        
        let path = directory + filename.withJPGFileExtension
        let thumbPath = directory + filename + "_thumbnail".withJPGFileExtension
        
        let newPath = directory + newFilename.withJPGFileExtension
        let newThumbPath = directory + newFilename + "_thumbnail".withJPGFileExtension
        
        let fileManager = FileManager()
        do {
            try fileManager.copyItem(atPath: path, toPath: newPath)
            try fileManager.copyItem(atPath: thumbPath, toPath: newThumbPath)
        } catch {
            return ("-1", "-1")
        }
        
        return (newPath, newThumbPath)
    }
    
    static func createDirectory() -> String? {
        return FileManagerHelper.createDirectory(.imageAttachments)
    }
    
    static func download(fromURL url: String, filename: String) -> Observable<ImageStorageItem> {
        let request = URLRequest(url: URL(string: url)!)
        
        return URLSession.shared.rx.data(request: request).map { (data) -> UIImage? in
            return UIImage(data: data)
        }
        .filterNil()
        .flatMap { (image) -> Observable<ImageStorageItem> in
            return ImageStorage.storeImage(originalImage: image, filename: filename)
        }
    }
    
    static func hasItemStoredOnFileSystem(filename: String) -> Bool {
        guard let directory = createDirectory() else {
            return false
        }
        
        let path = directory + filename.withJPGFileExtension
        let manager = FileManager()
        return manager.fileExists(atPath: path)
    }
    
    static func base64String(for image: UIImage, type: ImageType) -> String {
        let base64String: String?
        switch type {
        case .png:
            base64String = UIImagePNGRepresentation(image)?.base64EncodedString()
        case .jpg(let quality):
            base64String = UIImageJPEGRepresentation(image, CGFloat(quality))?.base64EncodedString()
        }
        return "data:image/\(type.identifier);base64,\(base64String ?? "")"
    }
}

private func retrieveImageFromPickerData(_ data: [String: AnyObject]) -> Observable<ImageStorageItem> {
    
    guard let originalImage = data[UIImagePickerControllerOriginalImage] as? UIImage else {
        fatalError()
    }
    
    return ImageStorage.storeImage(originalImage: originalImage)
}
