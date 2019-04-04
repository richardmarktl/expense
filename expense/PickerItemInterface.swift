//
//  PickerItemInterface.swift
//  InVoice
//
//  Created by Georg Kitz on 29.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

protocol PickerItemInterface: Equatable {
    var shortDesignName: String {get}
    var longName: String {get}
    var displayName: String {get}
    var hint: String? {get}
    static var all: [Self] {get}
    static func create(from rawValue: String) -> Self
}
