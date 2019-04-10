//
//  Language.swift
//  InVoice
//
//  Created by Georg Kitz on 29.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

// Note once 4.2 is released move to CaseIteratable
public enum Language: String {
    case en
    case de
    case da
    case es
    case fi
    case fr
    case it
    case nl
    case nb
    case ptPT = "pt-PT"
    case ptBR = "pt-BR"
    case sv
    
    static func create(from countryCode: String) -> Language {
        if let value = Language(rawValue: countryCode) {
            return value
        }
        return .en
    }
}

public extension String {
    var asLanguage: Language {
        return Language.create(from: self)
    }
}
