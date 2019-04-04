//
//  ObservableType+Job.swift
//  InVoice
//
//  Created by Georg Kitz on 5/22/18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

public extension ObservableType where E: Invoice {
    func mapToJob() -> Observable<Job> {
        return self.map { value -> Job in
            return value
        }
    }
}

public extension ObservableType where E: Offer {
    func mapToJob() -> Observable<Job> {
        return self.map { value -> Job in
            return value
        }
    }
}
