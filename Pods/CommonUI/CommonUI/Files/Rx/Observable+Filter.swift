//
//  Observable+Filter.swift
//  CommonUI
//
//  Created by Georg Kitz on 16.04.19.
//  Copyright © 2019 Georg Kitz. All rights reserved.
//

import RxSwift

public extension ObservableType where E == Bool {
    func filterTrue() -> Observable<E> {
        return self.flatMap { element -> Observable<E> in
            if element {
                return Observable.just(element)
            }
            return Observable.empty()
        }
    }
    
    func filterFalse() -> Observable<E> {
        return self.flatMap { element -> Observable<E> in
            if !element {
                return Observable.just(element)
            }
            return Observable.empty()
        }
    }
}
