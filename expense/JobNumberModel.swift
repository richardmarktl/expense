//
//  NumberModel.swift
//  InVoice
//
//  Created by Georg Kitz on 14.02.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

struct JobNumber {
    let valid: Bool
    let value: String
    
    static let invalidJobNumber: JobNumber = JobNumber(valid: false, value: "------")
}

class JobNumberModel {
    
    var containsValidJobNumber: Bool = false
    var jobNumberObservable: Observable<JobNumber>
    
    init(loadJobNumberObservable: Observable<String>, reachabilityObservable: Observable<Bool>) {
        
        let reachabilityChanges = reachabilityObservable.distinctUntilChanged()
        
        let isReachableObservable = reachabilityChanges
            .filter {$0 == true}
            .take(1)
        
        let isNotReachableObservable = reachabilityChanges
            .takeUntil(isReachableObservable)
            .filter {$0 == false}
            .take(1)
            .map { _ -> JobNumber in JobNumber.invalidJobNumber }
        
        let loadDataObservable = isReachableObservable.flatMap { (_) -> Observable<JobNumber> in
            return loadJobNumberObservable.map({ (value) -> JobNumber in
                return JobNumber(valid: true, value: value)
            }).retry(2)
        }
        
        jobNumberObservable = Observable.merge(isNotReachableObservable, loadDataObservable)
    }
}
