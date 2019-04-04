//
//  NSDate+Additions.swift
//  meisterwork
//
//  Created by Georg Kitz on 17/03/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

import Foundation

enum WhenSeparator {
    case none, standard, custom(begin: String, end: String)
    
    var from: String {
        switch self {
        case .standard:
            return NSLocalizedString("From", comment: "") + " "
        case .custom(let begin, _):
            return begin + " "
        default:
            return ""
        }
    }
    
    var to: String {
        switch self {
        case .standard:
            return " " + NSLocalizedString("to", comment: "") + " "
        case .custom(_, let end):
            return " " + end + " "
        default:
            return " - "
        }
    }
}

extension Date {
    
    /**
     calculates delta between 2 dates and returns it as hh:mm string, could be 99:10
     */
    func timeDeltaStringHoursMinutes(_ date: Date) -> String {
        return timeDelta(date).asTimeHoursMinuteString
    }
    
    /**
     calculates delta between 2 dates and returns it as mm:ss string, could be 99:10
     */
    func timeDeltaStringMinutesSeconds(_ date: Date) -> String {
        return timeDelta(date).asTimeMinuteSecondString
    }
    
    /**
     calculates the delta between 2 dates as hours
     */
    func timeDeltaInHours(_ date: Date) -> Float {
        
        let d = Float(timeDelta(date))
        return d / 60.0 / 60.0
    }
    
    /**
     calculates the delta between 2 dates as seconds
     */
    func timeDelta(_ date: Date) -> TimeInterval {
        let i1 = timeIntervalSince1970
        let i2 = date.timeIntervalSince1970
        
        return abs(i1 - i2)
    }
    
    /**
     checks if the date is older than x days
     */
    func olderThan(_ days: Int) -> Bool {
        let date = Date().addingTimeInterval(-60 * 60 * 24 * TimeInterval(days))
        return date.timeIntervalSince1970 > self.timeIntervalSince1970
    }
    
    /**
     returns the workday of this date (enum)
     */
    var workday: Workday {
        let calendar = Calendar.current
        let component = (calendar as NSCalendar).components([NSCalendar.Unit.weekday], from: self)
        return Workday(fromIntegerDay: component.weekday!)!
    }
    
    /**
     returns the seconds since midnight
     */
    var timeIntervalSinceMidnight: TimeInterval {
        let calendar = Calendar.current
        let component = (calendar as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second], from: self)
        
        let h = component.hour ?? 0
        let m = component.minute ?? 0
        let s = component.second ?? 0
        
        return TimeInterval(h * 60 * 60 + m * 60 + s)
    }
    
    /**
     adds 24hrs to the date and returns a new date
     */
    var nextDay: Date {
        return self.addingTimeInterval(60 * 60 * 24)
    }
    
    /**
     same as nextDay
     */
    var tomorrow: Date {
        return nextDay
    }
    
    /**
     Gives you the start of the day of the date
     */
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /**
     Returns the end of the day of the date
     */
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDay, options: NSCalendar.Options())!
    }
    
    func components(with componentElements: Set<Calendar.Component> = [.day, .month, .year, .hour, .minute, .second]) -> DateComponents {
        return Calendar.current.dateComponents(componentElements, from: self)
    }
    
    /**
     checks if dates are on the same day
     */
    func isSameDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: self)
    }
    
    /**
     returns the localized string for the day e.g. 'Monday'
     */
    func dayString() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter.string(from: self)
    }
    
    func adjustTimeToSecondsFromMidnight(_ seconds: TimeInterval) -> Date {
        return startOfDay.addingTimeInterval(seconds)
    }
    
    func isInRange(start: Date, end: Date) -> Bool {
        let secs = timeIntervalSince1970
        return secs > start.timeIntervalSince1970 && secs < end.timeIntervalSince1970
    }
    
    func flattendSecondsDate() -> Date {
        let timeInterval = floor(timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }
    
    static func when(from begin:Date?, to end: Date?, separator: WhenSeparator) -> String {
        var when = ""
        if let begin = begin {
            when += separator.from + begin.asString(.short, timeStyle: .short)
        }
        
        if let end = end {
            when += separator.to + end.asString(.short, timeStyle: .short)
        }
        return when.uppercaseFirst
    }
}

//
//  NSTimeInterval+MinuteString.swift
//  meisterwork
//
//  Created by Georg Kitz on 29/03/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//

extension TimeInterval {
    var asTimeMinuteSecondString: String {
        
        let startInterval = Int(self)
        let minutes = abs(startInterval / 60)
        let seconds = abs(startInterval % 60)
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var asTimeHoursMinuteString: String {
        
        let startInterval = Int(self)
        let minutes = abs((startInterval / 60) % 60)
        let hours = abs(startInterval / 60 / 60)
        
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var asTimeHoursMinuteSecondsString: String {
        
        let startInterval = Int(self)
        let seconds = abs(startInterval % 60)
        let minutes = abs((startInterval / 60) % 60)
        let hours = abs(startInterval / 60 / 60)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var asMinutesString: String {
        
        let startInterval = Int(self)
        let minutes = abs(startInterval / 60)
        
        return String(minutes)
    }
    
    var asRelativeString: String {
        
        let startInterval = Int(self)
        let minutes = abs((startInterval / 60) % 60)
        let hours = abs(startInterval / 60 / 60)
        
        var str = ""
        if hours > 0  {
            str += String(format: "%d%@ ", hours, NSLocalizedString("hrs", comment: ""))
        }
        str += String(format:"%d%@", minutes, NSLocalizedString("min", comment: ""))
        
        return str
    }
}

enum Workday: String {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    static var workdays: [Workday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    
    init?(fromIntegerDay: Int) {
        
        let day = fromIntegerDay - 1
        if day < 0 || fromIntegerDay > 7 {
            return nil
        }
        
        self.init(rawValue: Workday.workdays[day].rawValue)
    }
}

extension String {
    var uppercaseFirst: String {
        let p1 = prefix(1).uppercased()
        let p2 = dropFirst()
        return p1 + p2
    }
}
