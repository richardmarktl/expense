//
//  RxFiltering.swift
//  InVoice
//
//  Created by Georg Kitz on 06/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

public extension ObservableType where E == Bool {
    public func filterTrue() -> Observable<E> {
        return self.flatMap { element -> Observable<E> in
            if element {
                return Observable.just(element)
            }
            return Observable.empty()
        }
    }
    
    public func filterFalse() -> Observable<E> {
        return self.flatMap { element -> Observable<E> in
            if !element {
                return Observable.just(element)
            }
            return Observable.empty()
        }
    }
}
