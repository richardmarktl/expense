//
//  Date+String.swift
//  Stargate
//
//  Created by Georg Kitz on 10/09/2017.
//  Copyright © 2017 DeliveryHero AG. All rights reserved.
//

import Foundation

public extension Date {

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

    func asString(_ dateStyle: DateFormatter.Style = .short, timeStyle: DateFormatter.Style = .short) -> String {
        Static.plainFormatter.dateStyle = dateStyle
        Static.plainFormatter.timeStyle = timeStyle
        return Static.plainFormatter.string(from: self)
    }
}
