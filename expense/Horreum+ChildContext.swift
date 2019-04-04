//
//  Horreum+ChildContext.swift
//  InVoice
//
//  Created by Richard Marktl on 06.12.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import Horreum

extension Horreum {
    open func childContext() -> NSManagedObjectContext {
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = mainContext
        childContext.stalenessInterval = 0
        return childContext
    }
}
