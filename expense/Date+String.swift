//
//  Date+String.swift
//  Stargate
//
//  Created by Georg Kitz on 10/09/2017.
//  Copyright © 2017 DeliveryHero AG. All rights reserved.
//

import Foundation

extension Date {

    fileprivate struct Static {

        static let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
            return formatter
        }()

        static let plainFormatter: DateFormatter = {
            let formatter = DateFormatter()
            return formatter
        }()
    }
    
    var ISO8601DateTimeString: String {
        return Static.formatter.string(from: self)
    }
    
    func relativeString(prefixedWith prefix: String) -> String {
        let calendar = Calendar.current
        
        let today = Date()
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: today)
        let date2 = calendar.startOfDay(for: self)
        
        let compontents = calendar.dateComponents([.day], from: date1, to: date2)
        let dayDifference = compontents.value(for: .day)!
        
        if dayDifference == 0 {
            return prefix + " " + R.string.localizable.today()
        } else if dayDifference == -1 {
            return prefix + " " + R.string.localizable.yesterday()
        } else if dayDifference == 1 {
            return prefix + " " + R.string.localizable.tomorrow()
        } else if dayDifference < -1 {
            return prefix + " " + R.string.localizable.xDaysAgo(abs(dayDifference))
        } else {
            return prefix + " " + R.string.localizable.inXDays(dayDifference)
        }
    }

    func asString(_ dateStyle: DateFormatter.Style = .short, timeStyle: DateFormatter.Style = .short) -> String {
        Static.plainFormatter.dateStyle = dateStyle
        Static.plainFormatter.timeStyle = timeStyle
        return Static.plainFormatter.string(from: self)
    }
}
