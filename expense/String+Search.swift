//
//  String+Search.swift
//  InVoice
//
//  Created by Georg Kitz on 20/02/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

extension String {
    var asSearchString: String {
        return trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).lowercased()
    }
}
