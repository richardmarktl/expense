//
//  String+Error.swift
//  CommonUtil
//
//  Created by Georg Kitz on 2019-05-10.
//  Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation

extension String: Error {}

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
