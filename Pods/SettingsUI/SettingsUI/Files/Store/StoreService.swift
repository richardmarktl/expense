//
//  StoreService.swift
//  SettingsUI
//
//  Created by Richard Marktl on 2019-05-16.
//  Copyright (c) 2019 meisterwork. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift

public enum StoreServiceError: String, Error {
    case receiptExpired
    case neverHadASubscription
    case invalidSubscription
}

extension StoreServiceError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

public protocol StoreService {
    var productsObservable: Observable<[Product]> { get }
    var hasValidReceiptObservable: Observable<Bool> { get }
    var hasValidReceipt: Bool { get }
    func loadProducts() -> Void
    func restorePurchase() -> Observable<Void>
}
