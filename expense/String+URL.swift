//
//  String+URL.swift
//  InVoice
//
//  Created by Georg Kitz on 20.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

extension String {
    var asFileUrl: URL {
        return URL(fileURLWithPath: self)
    }
}
