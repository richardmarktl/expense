//
//  AnnotationMimeType.swift
//  InVoice
//
//  Created by Georg Kitz on 25/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

enum AnnotationMimeType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case text = "text/plain"
}

extension AnnotationMimeType {
    
    func uniqueFilename() -> String {
        
        let name = UUID().uuidString.lowercased()
        return extendFilenameWithEnding(name)
    }
    
    func extendFilenameWithEnding(_ name: String) -> String {
        switch self {
        case .jpeg:
            return name + ".jpg"
        case .png:
            return name + ".png"
        case .text:
            return name + ".txt"
        }
    }
}
