//
//  String+Error.swift
//  Stargate
//
//  Created by Georg Kitz on 10/09/2017.
//  Copyright © 2017 DeliveryHero AG. All rights reserved.
//

import Foundation

extension String: Error {}

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
