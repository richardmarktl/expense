//
//  Array+Order+Extension.swift
//  InVoice
//
//  Created by Georg Kitz on 06.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

protocol Sortable {
    var sort: Int16 {get}
    var createdTimestamp: Date? {get}
}

extension Order: Sortable {}
extension Attachment: Sortable {}
extension Recipient: Sortable {}

extension Array where Iterator.Element: Attachment {
    
    func asSorted() -> [Iterator.Element] {
        return sorted(by: comperator)
    }
}

extension Array where Iterator.Element: Order {
    
    func asSorted() -> [Iterator.Element] {
        return sorted(by: comperator)
    }
}

extension Array where Iterator.Element: Recipient {
    
    func asSorted() -> [Iterator.Element] {
        return sorted(by: comperator)
    }
}

fileprivate let comperator: (Sortable, Sortable) -> Bool = { (e1: Sortable, e2: Sortable) -> Bool in
    if e1.sort != 0 || e2.sort != 0 {
        return e1.sort < e2.sort
    }
    return e1.createdTimestamp?.timeIntervalSince1970 ?? 0 < e2.createdTimestamp?.timeIntervalSince1970 ?? 0
}
