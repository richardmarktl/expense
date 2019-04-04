//
//  SKRefreshReceipt+Rx.swift
//  InVoice
//
//  Created by Georg Kitz on 09.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift
import RxCocoa

public class SKReceiptRefreshRequestDelegateProxy: DelegateProxy<SKReceiptRefreshRequest, SKRequestDelegate>,
    DelegateProxyType, SKRequestDelegate {
    
    public init(parentObject: SKReceiptRefreshRequest) {
        super.init(parentObject: parentObject, delegateProxy: SKReceiptRefreshRequestDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { SKReceiptRefreshRequestDelegateProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: SKReceiptRefreshRequest) -> SKRequestDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: SKRequestDelegate?, to object: SKReceiptRefreshRequest) {
        object.delegate = delegate
    }
    
    let responseSubject = PublishSubject<SKReceiptRefreshRequest>()
    
    public func requestDidFinish(_ request: SKRequest) {
        guard let request = request as? SKReceiptRefreshRequest else {
            responseSubject.onError("Wrong Request Type")
            return 
        }
        responseSubject.onNext(request)
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        responseSubject.onError(error)
    }
    
    deinit {
        responseSubject.on(.completed)
    }
}

extension SKReceiptRefreshRequest {
    
    public func createRxDelegateProxy() -> SKReceiptRefreshRequestDelegateProxy {
        return SKReceiptRefreshRequestDelegateProxy(parentObject: self)
    }
    
}

extension Reactive where Base: SKReceiptRefreshRequest {
    
    public var delegate: DelegateProxy<SKReceiptRefreshRequest, SKRequestDelegate> {
        return SKReceiptRefreshRequestDelegateProxy.proxy(for: base)
    }
    
    public var refresh: Observable<SKReceiptRefreshRequest> {
        return SKReceiptRefreshRequestDelegateProxy.proxy(for: base).responseSubject.asObservable()
    }
}
