//
//  BaseItem.swift
//  InVoice
//
//  Created by Georg Kitz on 18/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

extension BaseItem {
    var hasRemoteId: Bool {
        return remoteId != 0 && remoteId != DefaultData.TestRemoteID
    }
}
