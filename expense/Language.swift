//
//  Language.swift
//  InVoice
//
//  Created by Georg Kitz on 29.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

// Note once 4.2 is released move to CaseIteratable
enum Language: String, PickerItemInterface {
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
    
    static var all: [Language] {
        return [.en, .de, .da, .es, .fi, .fr, .it, .nl, .nb, .ptPT, .ptBR, .sv]
    }
    
    var shortDesignName: String {
        switch self {
        case .en:
            return "\u{1F1EC}\u{1F1E7}"
        case .de:
            return "\u{1F1E9}\u{1F1EA}"
        case .da:
            return "\u{1F1E9}\u{1F1F0}"
        case .es:
            return "\u{1F1EA}\u{1F1F8}"
        case .fi:
            return "\u{1F1EB}\u{1F1EE}"
        case .fr:
            return "\u{1F1EB}\u{1F1F7}"
        case .it:
            return "\u{1F1EE}\u{1F1F9}"
        case .nl:
            return "\u{1F1F3}\u{1F1F1}"
        case .nb:
            return "\u{1F1F3}\u{1F1F4}"
        case .ptBR:
            return "\u{1F1E7}\u{1F1F7}"
        case .ptPT:
            return "\u{1F1F5}\u{1F1F9}"
        case .sv:
            return "\u{1F1F8}\u{1F1EA}"
        }
    }
    
    var longName: String {
        return NSLocalizedString(rawValue, comment: "")
    }
    
    var displayName: String {
        return shortDesignName + " " + longName
    }
    
    var hint: String? {
        return R.string.localizable.languageSelectorHint()
    }
}

extension String {
    var asLanguage: Language {
        return Language.create(from: self)
    }
}
