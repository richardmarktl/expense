//
//  ReachabilityManager.swift
//  meisterwork
//
//  Created by Georg Kitz on 01/05/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import Reachability

let reachabilityManager = ReachabilityManager()

public func reachabilityColsure() -> Observable<Bool> {
    return reachabilityManager.reachable
}

final class ReachabilityManager {
    
    fileprivate let _reachable = ReplaySubject<Bool>.create(bufferSize: 1)
    var reachable: Observable<Bool> {
        return _reachable.asObservable()
    }
    
    fileprivate let reachability: Reachability = Reachability(hostName: "www.google.com")
    
    init() {
        
        reachability.reachableBlock = { [weak self] _ in
            DispatchQueue.main.async {
                logger.verbose("Google reachable")
                self?._reachable.onNext(true)
            }
        }
        
        reachability.unreachableBlock = { [weak self] _ in
            DispatchQueue.main.async {
                logger.verbose("Google not reachable")
                self?._reachable.onNext(false)
            }
        }
        
        reachability.startNotifier()
        _reachable.onNext(reachability.isReachable())
    }
}
