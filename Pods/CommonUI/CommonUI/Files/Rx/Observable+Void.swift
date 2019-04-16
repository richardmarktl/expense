//
//  Observable+Void.swift
//  CommonUI
//
//  Created by Georg Kitz on 15.04.19.
//  Copyright © 2019 Georg Kitz. All rights reserved.
//

import Foundation
import RxSwift

public extension ObservableType {
    // Useful for mapping an Observable<Whatever> into an Observable<Void> to hide details.
    func mapToVoid() -> Observable<Void> {
        return self.map { _ -> Void in
            return ()
        }
    }
}
