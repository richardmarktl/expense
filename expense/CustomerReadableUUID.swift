//
//  CustomerReadableUUID.swift
//  InVoice
//
//  Created by Georg Kitz on 09/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

extension String {
    var shortenedUUIDString: String {
        return components(separatedBy: "-").first ?? self
    }
}
