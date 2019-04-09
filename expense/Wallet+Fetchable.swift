//
//  Wallet+Fetchable.swift
//  expense
//
//  Created by Richard Marktl on 09.04.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio


enum WalletType: Int32 {
    case personal = 0
    case business = 1
}

extension Wallet: Fetchable, Createable {
    public typealias CreatedType = Wallet
    public typealias FetchableType = Wallet
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    public static func create(in context: NSManagedObjectContext) -> Wallet {
        let instance = Wallet(inContext: context)
        instance.uuid = UUID().uuidString.lowercased()
        instance.createdTimestamp = Date()
        instance.updatedTimestamp = Date()
        instance.localUpdateTimestamp = Date()
        instance.type = WalletType.personal.rawValue
        return instance
    }
    
    var walletType: WalletType {
        get {
            guard let walletType = WalletType(rawValue: type) else {
                return .personal
            }
            return walletType
        }
        set {
            type = newValue.rawValue
        }
    }
}
