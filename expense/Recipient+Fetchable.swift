//
//  Recipient+Fetchable.swift
//  InVoice
//
//  Created by Richard Marktl on 14.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import CoreDataExtensio
import RxSwift

/// This state also exists in the Database, unlike the job state, this state is not generated and part of
/// of database and api model.
enum RecipientState: Int32 {
    case notSend = 0
    case sent = 1
    case deferral = 2
    case bounced = 3
    case softBounce = 4
    case opened = 5
    case rejected = 6
    case invalid = 7
    case downloaded = 8
    case paid = 100
    case signed = 20

    var color: UIColor {
        switch self {
        case .notSend:
            return UIColor.main
        case .opened:
            return UIColor.orangeish
        case .downloaded:
            return UIColor.purpleish
        case .signed:
            return UIColor.rose
        default:
            return UIColor.greenish
        }
    }

    var title: String {
        switch self {
        case .notSend:
            return R.string.localizable.stateNotSend()
        case .opened:
            return R.string.localizable.stateOpened()
        case .downloaded:
            return R.string.localizable.stateOpenedLink()
        case .signed:
            return R.string.localizable.stateSigned()
        default:
            return R.string.localizable.stateSent()
        }
    }
}

extension Recipient: Fetchable {
    public typealias FetchableType = Recipient
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    /// alywas return zero because the recipients are sorted in the Sortable
    /// through the created timestamp
    var sort: Int16 {
        get {
            return 0
        }
    }

    var typedState: RecipientState {
        return RecipientState(rawValue: state) ?? .notSend
    }
    
    /// The prefix is used to make it easier for us to find the signature in the image folder.
    /// cs_<uuid> is short for (c)ustomer (s)ignature
    var signatureImagePath: String? {
        if let uuid = uuid {
            return "cs_" + uuid
        }
        return nil
    }

    var signatureNameAndDate: String {
        if let name = signatureName {
            if let date = signedOn {
                return "\(name), \(date.asString(timeStyle: .none))"
            }
            return name
        }
        return ""
    }
    
    /// This method will try to load the recipient signature of user.
    ///
    /// - Parameter recipient: a recipient object
    /// - Returns: an Observable
    func loadRecipientSignature() -> Observable<[String: Any]>? {
        guard let signature = signature, let localPath = signatureImagePath else {
            return nil
        }
        
        let name = signatureNameAndDate
        let observable: Observable<ImageStorageItem>
        if ImageStorage.hasItemStoredOnFileSystem(filename: localPath) {
            observable = ImageStorage.loadImage(for: localPath)
        } else {
            observable = ImageStorage.download(fromURL: signature, filename: localPath)
        }
        
        return observable.map({ (item) -> [String: Any] in
            return [
                "name": name,
                "signature": ImageStorage.base64String(for: item.image, type: .png)
            ]
        })
    }
}
