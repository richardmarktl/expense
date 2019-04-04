//
//  SignatureError.swift
//  InVoice
//
//  Created by Georg Kitz on 21.11.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

enum SignatureError: Error {
    case failed(with: String)
}

extension SignatureError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failed(let message):
            return message;
        }
    }
}
