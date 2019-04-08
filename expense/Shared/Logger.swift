//
//  Logger.swift
//  InVoice
//
//  Created by Georg Kitz on 09.11.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import SwiftyBeaver

// MARK: - SwiftyBeaver init
let logger = SwiftyBeaver.self

func setupLogger() {
    let console = ConsoleDestination()
    let file = FileDestination()
    
    let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    file.logFileURL = url?.appendingPathComponent("debug.log")
    
    logger.addDestination(console)
    logger.addDestination(file)
}
