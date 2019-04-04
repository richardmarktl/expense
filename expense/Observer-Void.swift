//
//  Observer-Void.swift
//  Stargate
//
//  Created by Georg Kitz on 20/09/2017.
//  Copyright © 2017 DeliveryHero AG. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    // Useful for mapping an Observable<Whatever> into an Observable<Void> to hide details.
    public func mapToVoid() -> Observable<Void> {
        return self.map { _ -> Void in
            return ()
        }
    }
}
