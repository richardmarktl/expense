//
//  UserDefaults+LastUpload.swift
//  InVoice
//
//  Created by Georg Kitz on 24/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

public extension UserDefaults {
    class func store(lastUpload: Date? = Date()) {
        let defaults = UserDefaults.standard
        defaults.set(lastUpload, forKey: "at_meisterwork_last_upload")
        defaults.synchronize()
    }
    
    class var lastUploadDate: Date? {
        return UserDefaults.standard.object(forKey: "at_meisterwork_last_upload") as? Date
    }
    
    class var lastUploadDateObservable: Observable<Date> {
        return UserDefaults.standard.rx.observe(Date.self, "at_meisterwork_last_upload").filterNil().distinctUntilChanged()
    }
    
    class var lastUpdateDaysAgoObservable: Observable<Int> {
        return lastUploadDateObservable.map({ (date) -> Int in
            
            let calendar = Calendar.current
            let now = calendar.startOfDay(for: Date())
            let last = calendar.startOfDay(for: date)
            
            let component = calendar.dateComponents([.day], from: last, to: now)
            
            return component.day ?? 0
        })
    }
}
