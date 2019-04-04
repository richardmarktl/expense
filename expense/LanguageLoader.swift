
//
//  LanguageLoader.swift
//  InVoice
//
//  Created by Georg Kitz on 29.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation

struct LanguageLoader {
    private static var currentLanguageBundle = Bundle.main
    static func updateCurrentLanguageBundle(to language: String?) {
        
        let languageCode = (language ?? Locale.current.languageCode)?.baseBundleTransformed
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"), let langBundle = Bundle(path: path) {
            currentLanguageBundle = langBundle
        } else {
            currentLanguageBundle = Bundle.main
        }
    }
    static func localizedString(_ key: String, parameters: [CVarArg]) -> String {
        return String(format: currentLanguageBundle.localizedString(forKey: key, value: nil, table: nil), arguments: parameters)
    }
}

extension String {
    func localizeFromCurrentSelectedBundle(_ parameters: CVarArg...) -> String {
       return LanguageLoader.localizedString(self, parameters: parameters)
    }
    
    func localizedUserValue(for localization: JobLocalization?) -> String {
        return localization?.value(forKey: self) as? String ?? localizeFromCurrentSelectedBundle()
    }
}

extension String {
    var baseBundleTransformed: String {
        return self == "en" ? "Base" : self
    }
}
