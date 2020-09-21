//
//  DateExtensions.swift
//  schema
//
//  Created by Victor Forsgren on 2020-09-18.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    func dayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd/MM"
        formatter.locale =  Locale(identifier: "sv_SE")
        let dateString = formatter.string(from: self)
        return dateString
    }
    func localString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        return DateFormatter.localizedString(from: self, dateStyle: dateStyle, timeStyle: timeStyle)
    }
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
}
class DateExtensions {
    static func newDateFromHourMinuteString(hourMinuteString: String, from: Date) -> Date {
        let split = hourMinuteString.split(separator: ":")
        let date = Calendar.current.date(bySettingHour: (split[0] as NSString).integerValue, minute: (split[1] as NSString).integerValue, second: 0, of: from)!
        return date
    }
    static func getMinutesFromDates(from: Date, to: Date) -> Int{
        let cal = Calendar.current
        let components = cal.dateComponents([.minute], from: from, to: to)
        let minuteDiff = components.minute!
        return minuteDiff
    }
    static func getWeekFrom(date: Date) -> Int {
        let calendar = NSCalendar.current
        let component = calendar.component(.weekOfYear, from: date)
        return component
    }
}
