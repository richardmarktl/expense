//
//  FuckupResolver.swift
//  InVoice
//
//  Created by Georg Kitz on 27.02.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import Horreum
import CoreData
import CoreDataExtensio
import Crashlytics

struct FuckupResolver {
    typealias FuckUpUploadBlock = () -> Observable<Void>
    private struct Static {
        static let didRunFuckUpResolver: String = "did_run_fuck_up_resolver"
    }
    
    private let storage: UserDefaults
    private let session: URLSession
    private let context: NSManagedObjectContext
    
    init(userDefaults: UserDefaults = UserDefaults.standard, context: NSManagedObjectContext) {
        storage = userDefaults
        self.context = context
        
        session = URLSession(configuration: .default)
    }
    
    /// We try to resolve the fuck up we currently have by trying to reupload the files
    ///
    /// - Returns: Observable when done
    func resolve() -> Observable<Void> {
        if storage.bool(forKey: Static.didRunFuckUpResolver)  {
            return Observable.empty()
        }
        
        logger.verbose("Start resolver")
        return uploadLogoIfNeeded()
            .concat(uploadRecipientSignaturesIfNeeded())
            .concat(uploadAttachmentsIfNeeded())
            .concat(uploadInvoicesWithSignatureIfNeeded())
            .concat(uploadOffersWithSignatureIfNeeded())
            .takeLast(1)
            .do(onNext: { (_) in
                try? self.context.save()
                self.storage.set(true, forKey: Static.didRunFuckUpResolver)
                self.storage.synchronize()
            }, onError: { (error) in
                logger.error("Resolver errored \(error)")
                Crashlytics.sharedInstance().recordError(error)
            }, onCompleted: {
                logger.verbose("Completed")
            })
    }
    
    /// Uploads the logo if we have one
    ///
    /// - Returns: Observable
    fileprivate func uploadLogoIfNeeded() -> Observable<Void> {
        let account = Account.current(context: context)
        let upload = {
            return AccountRequest.uploadLogo(for: account).do(onNext: nil, onError: { (error) in
                logger.error("AccountRequest: \(error)")
                Crashlytics.sharedInstance().recordError(error)
            }).catchErrorJustReturn(account).mapToVoid().take(1)
        }
        
        return checkResourceAvailableAndPerformUploadIfNeeded(for: account.logoFile, upload: upload)
        
    }
    
    /// Uploads all signatures of recipients
    ///
    /// - Returns: Observable
    fileprivate func uploadRecipientSignaturesIfNeeded() -> Observable<Void> {
        return checkItems(items: Recipient.allObjects(context: context), urlKeyPath: \Recipient.signature, upload: { (item) in
            return {
                return RecipientRequest.uploadSignature(for: item).do(onNext: nil, onError: { (error) in
                    logger.error("RecipientRequest: \(error)")
                    Crashlytics.sharedInstance().recordError(error)
                }).catchErrorJustReturn(item).mapToVoid()
            }
        })
    }
    
    /// Uploads all attachments
    ///
    /// - Returns: Observable
    fileprivate func uploadAttachmentsIfNeeded() -> Observable<Void> {
        return checkItems(items: Attachment.allObjects(context: context), urlKeyPath: \Attachment.file, upload: { (item) in
            return {
                return AttachmentRequest.uploadAttachmentContent(item).do(onNext: nil, onError: { (error) in
                    logger.error("AttachmentRequest: \(error)")
                    Crashlytics.sharedInstance().recordError(error)
                }).catchErrorJustReturn(item).mapToVoid()
            }
        })
    }
    
    /// Uploads invoice signatures
    ///
    /// - Returns: Observable
    fileprivate func uploadInvoicesWithSignatureIfNeeded() -> Observable<Void> {
        let predicate = NSPredicate(format: "signature != NULL")
        return checkItems(items: Invoice.allObjects(matchingPredicate: predicate, context: context), urlKeyPath: \Invoice.signature, upload: { (item) in
            return {
                return InvoiceRequest.uploadSignature(item).do(onNext: nil, onError: { (error) in
                    logger.error("InvoiceRequest: \(error)")
                    Crashlytics.sharedInstance().recordError(error)
                }).catchErrorJustReturn(item).mapToVoid()
            }
        })
    }
    
    /// Uploads offer signatures
    ///
    /// - Returns: Observable
    fileprivate func uploadOffersWithSignatureIfNeeded() -> Observable<Void> {
        let predicate = NSPredicate(format: "signature != NULL")
        return checkItems(items: Offer.allObjects(matchingPredicate: predicate, context: context), urlKeyPath: \Offer.signature, upload: { (item) in
            return {
                return OfferRequest.uploadSignature(item).do(onNext: nil, onError: { (error) in
                    logger.error("OfferRequest: \(error)")
                    Crashlytics.sharedInstance().recordError(error)
                }).catchErrorJustReturn(item).mapToVoid()
            }
        })
    }
    
    /// Iterates over all items, checks if the file exists on the server and triggers the `upload` closure if the file doesn't exist
    ///
    /// - Parameters:
    ///   - items: items we potentially want to upload
    ///   - urlKeyPath: the property that holds the value for the url we want to check
    ///   - upload: the closure that we trigger to upload the data
    /// - Returns: Observable
    fileprivate func checkItems<T>(items: [T], urlKeyPath: KeyPath<T, String?>, upload: @escaping (T) -> () -> Observable<Void>) -> Observable<Void> {
        
        var observable = Observable.just(())
        
        items.forEach { (item) in
            let loader: () -> Observable<Void> = upload(item)
            let itemObs = checkResourceAvailableAndPerformUploadIfNeeded(for: item[keyPath: urlKeyPath], upload: loader)
            observable = observable.concat(itemObs)
        }
        
        return observable.takeLast(1)
    }
    
    /// Checks if the given url exists on the server otherwise it triggers the upload blog
    ///
    /// - Parameters:
    ///   - urlString: the resource we want to check on our server
    ///   - upload: the closure we want to trigger if the resource doesn't exist
    /// - Returns: Observable
    fileprivate func checkResourceAvailableAndPerformUploadIfNeeded(for urlString: String?, upload: @escaping FuckUpUploadBlock) -> Observable<Void> {
        
        guard let urlString = urlString else {
            return Observable.just(())
        }
        
        return checkResourceIsAvailableRequest(for: urlString)
            .flatMap { (isAvailable) -> Observable<Void> in
                if isAvailable {
                    return Observable.just(())
                } else {
                    return upload().take(1)
                }
            }
            .catchErrorJustReturn(())
    }
    
    /// Makes a `HEAD` call to the given resource, if we get a `200` we return `true` otherwise `false`
    ///
    /// - Parameter urlString: resource we want to check
    /// - Returns: Observable
    fileprivate func checkResourceIsAvailableRequest(for urlString: String) -> Observable<Bool> {
        
        let s3SpecificUrlString = urlString
            .replacingOccurrences(of: "staging.invoicebot.io", with: "s3.eu-central-1.amazonaws.com/staging.invoicebot.io")
            .replacingOccurrences(of: "files.invoicebot.io", with: "s3.eu-central-1.amazonaws.com/files.invoicebot.io")
        
        guard let request = URLRequest.from(urlString: s3SpecificUrlString) else {
            return Observable.empty()
        }
        
        return Observable.create({ (subscriber) -> Disposable in
            let dataTask = self.session.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    logger.error("Error while trying to check S3 data: \(error)")
                    subscriber.onNext(false)
                    subscriber.onCompleted()
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    logger.verbose("\(s3SpecificUrlString) found on S3")
                    subscriber.onNext(true)
                    subscriber.onCompleted()
                } else {
                    logger.error("\(s3SpecificUrlString) *not* found")
                    subscriber.onNext(false)
                    subscriber.onCompleted()
                }
            }
            
            dataTask.resume()
            
            return Disposables.create {
                dataTask.cancel()
            }
        })
    }
}

extension URLRequest {
    static func from(urlString: String?) -> URLRequest? {
        guard let urlString = urlString, let s3Url = URL(string: urlString) else {
            return nil
        }
        
        var request = URLRequest(url: s3Url)
        request.httpMethod = "HEAD"
        return request
    }
}
