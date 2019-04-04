//
//  NSUserDefaults+Token.swift
//  meisterwork
//
//  Created by Georg Kitz on 05/02/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    class var appGroup: UserDefaults {
        return AppGroup.appGroup
    }
    
    fileprivate struct AppGroup {
        static let appGroup = UserDefaults(suiteName: Bundle.main.infoDictionary!["APP_GROUP"] as? String)!
    }
    
    fileprivate struct Token {
        static let kIdentifierTokenKey = "at_meisterwork_token"
        static let kTokenRequestedKey = "at_meisterwork_token_requested"
        static let kDeviceIdKey = "at_meisterwork_device_id_key"
    }
    
    /**
     Stores the validated auth token from the server
     - parameter token: the token
     */
    func store(token: String?) {
        set(token, forKey: Token.kIdentifierTokenKey)
        synchronize()
    }
    
    /**
     Stores the date when the token uid + token was requested
     - parameter token: the token
     */
    func store(tokenRequestDate date: Date?) {
        set(date, forKey: Token.kTokenRequestedKey)
        synchronize()
    }
    
    func store(deviceIdentifier: Int64?) {
        set(deviceIdentifier, forKey: Token.kDeviceIdKey)
        synchronize()
    }
    
    /**
     Clears the data
     */
    func clearToken() {
        store(token: nil)
        store(tokenRequestDate: nil)
        store(deviceIdentifier: nil)
    }
    
    /**
     - returns: the token if we have it
     */
    func token() -> String? {
        return string(forKey: Token.kIdentifierTokenKey)
    }
    
    /**
     - returns: the date the token was requested
     */
    func tokenRequestDate() -> Date? {
        return object(forKey: Token.kTokenRequestedKey) as? Date
    }
    
    func deviceIdentifier() -> Int? {
        return integer(forKey: Token.kDeviceIdKey)
    }
    
    /**
     - returns: `true` if we have a stored token
     */
    func hasToken() -> Bool {
        return token() != nil
    }
    
    /**
     - returns: `true` if we have a stored date
     */
    func hasRequestedToken() -> Bool {
        return tokenRequestDate() != nil
    }
    
    func migrate(to userDefaults: UserDefaults) {
        if userDefaults.hasToken() || userDefaults.hasRequestedToken() {
            logger.debug("No migration of UserDefaults needed.")
            return
        }
        
        userDefaults.store(token: token())
        userDefaults.store(tokenRequestDate: tokenRequestDate())
        
        logger.debug("Migration of UserDefaults done.")
    }
}
