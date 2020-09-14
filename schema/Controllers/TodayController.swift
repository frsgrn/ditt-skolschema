//
//  TodayDelegate.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-12.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import SwiftUI

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

struct TimetableObjectLoad {
    var eventList: [Event] = []
    let week: Int
    let dayNum: Int
    let fetchError: FetchError?
}


class TodayController: ObservableObject {
    @Published var eventList: [Event] = []
    @Published var fetchError: FetchError? = nil
    @Published var hasLoaded: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var currentDate: Date = Date()
    
    @ObservedObject var settings = UserSettings()
    
    @Published var timetableObjectLoads: [TimetableObjectLoad] = []
    
    func load(profile: Profile?) {
        self.fetchError = nil
        self.eventList = []
        self.hasLoaded = false
        
        let dayToLoad: Date = self.selectedDate
        
        if (profile == nil) {
            self.fetchError = FetchError(message: "Ingen profil vald")
            return
        }
        if (profile!.signature != nil) {
            Skola24Wrapper.getSignature(userId: profile!.signature ?? "") { (signature, fetchError) -> () in
                if (fetchError != nil) {
                    self.fetchError = fetchError
                    return
                }
                else if (signature == nil) {
                    self.fetchError = FetchError(message: "Kunde inte hämta signatur")
                    return
                }
                self.fetchAndSetObjectTimetable(selection: signature ?? "", selectionType: 4, date: dayToLoad, profile: profile!)
            }
            return
        }
        if (profile!.classGuid != nil) {
            fetchAndSetObjectTimetable(selection: profile!.classGuid!, selectionType: 0, date: dayToLoad, profile: profile!)
        }
        else if (profile!.teacherGuid != nil) {
            fetchAndSetObjectTimetable(selection: profile!.teacherGuid!, selectionType: 7, date: dayToLoad, profile: profile!)
        }
    }
    
    private func fetchAndSetObjectTimetable(selection: String, selectionType: Int, date: Date, profile: Profile) {
        if (TodayController.getDayNumberOfWeek(from: date) - 1 > 5 || TodayController.getDayNumberOfWeek(from: date) - 1 == 0) {
            self.addTimetableObjectLoad(eventList: [], week: WeekController.getWeekFrom(date: self.selectedDate), dayNum: TodayController.getDayNumberOfWeek(from: date), fetchError: nil)
            return
        }
        Skola24Wrapper.getObjectTimetable(selection: selection, selectionType: selectionType, school: School(unitGuid: profile.schoolGuid ?? "", unitId: "Skola", hostName: profile.domain ?? ""), timeframe: Timeframe(start: date.startOfWeek!, end: date.endOfWeek!, dayOfWeek: TodayController.getDayNumberOfWeek(from: date) - 1), selectedDate: date) { (eventList, fetchError) -> () in
            if (fetchError != nil) {
                self.addTimetableObjectLoad(eventList: [], week: WeekController.getWeekFrom(date: self.selectedDate), dayNum: TodayController.getDayNumberOfWeek(from: date), fetchError: fetchError)
                return
            }
            var eventList_ = eventList
            if (self.settings.removeLunch) {
                eventList_ = eventList.filter {!$0.title.lowercased().contains("lunch")}
            }
            self.addTimetableObjectLoad(eventList: eventList_, week: WeekController.getWeekFrom(date: self.selectedDate), dayNum: TodayController.getDayNumberOfWeek(from: date), fetchError: nil)
        }
    }
    
    private func addTimetableObjectLoad(eventList: [Event], week: Int, dayNum: Int, fetchError: FetchError?) {
        let timetableObjectLoad = TimetableObjectLoad(eventList: eventList, week: week, dayNum: dayNum, fetchError: fetchError)
        if (getTimetableObjectLoadFromDayWeek(dayNum: dayNum, week: week) != nil) {
            setTimetableObjectLoad(timetableObjectLoad: timetableObjectLoad)
        }
        else {
            self.timetableObjectLoads.append(timetableObjectLoad)
        }
    }
    
    func setTimetableObjectLoad(timetableObjectLoad: TimetableObjectLoad) {
        for var m_timetableObjectLoad in self.timetableObjectLoads {
            if (m_timetableObjectLoad.week == timetableObjectLoad.week && m_timetableObjectLoad.dayNum == timetableObjectLoad.dayNum) {
                m_timetableObjectLoad = timetableObjectLoad
            }
        }
    }
    
    func getSelectedEventList() -> [Event] {
        if (getTimetableObjectLoadFromDate(date: self.selectedDate) == nil) {
            return []
        }
        else {
            return getTimetableObjectLoadFromDate(date: self.selectedDate)!.eventList
        }
    }
    
    func getTimetableObjectLoadFromDate(date: Date) -> TimetableObjectLoad? {
        let timetableObjectLoad: TimetableObjectLoad? = self.timetableObjectLoads.first(where: {
            return $0.dayNum == TodayController.getDayNumberOfWeek(from: date) && $0.week == WeekController.getWeekFrom(date: date)
        })
        return timetableObjectLoad
    }
    
    func getTimetableObjectLoadFromDayWeek(dayNum: Int, week: Int) -> TimetableObjectLoad? {
        let timetableObjectLoad: TimetableObjectLoad? = self.timetableObjectLoads.first(where: {
            $0.dayNum == dayNum && $0.week == week
        }) ?? nil
        return timetableObjectLoad
    }
    
    func startTimedDateFetch() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.currentDate = Date()
            
        }
    }
    
    static func minutesToHourMinuteString(minutes: Int) -> String {
        let hours: Int = minutes / 60;
        let minutes: Int = minutes % 60;
        var hoursString = ""
        var minutesString = ""
        if (hours > 0) {
            if (hours == 1) {
                hoursString = "\(hours) timma och "
            }
            else {
                hoursString = "\(hours) timmar och "
            }
        }
        if (minutes == 1) {
            minutesString = "\(minutes) minut"
        }
        else {
            minutesString = "\(minutes) minuter"
        }
        return hoursString + minutesString
    }
    
    func selectedSchoolDayIsOver () -> Bool {
        let timetableObjectLoad = self.getTimetableObjectLoadFromDate(date: self.selectedDate)
        guard let guardedTimetableObjectLoad = timetableObjectLoad else {
            return false
        }
        guard let lastEvent = guardedTimetableObjectLoad.eventList.last else {
            return true
        }
        if (self.currentDate > lastEvent.end) {
            return true
        }
        else {
            return false
        }
    }
    
    func assistantMessage() -> String {
        let timetableObject = self.getTimetableObjectLoadFromDate(date: self.selectedDate)
        if (timetableObject == nil) {
            return "Laddar..."
        }
        
        guard let guardedTimetableObject = timetableObject else {
            return "Fel..."
        }
        
        if (guardedTimetableObject.eventList.count == 0) {
            return "Ingenting på schemat idag"
        }
        
        for (_, event) in guardedTimetableObject.eventList.enumerated() {
            if (isActive(from: event.start, to: event.end)) {
                return "\(event.title) just nu, \(TodayController.minutesToHourMinuteString(minutes:TodayController.getMinutesFromDates(from: self.currentDate, to: event.end))) kvar"
            }
        }
        
        for (index, event) in guardedTimetableObject.eventList.enumerated() {
            if (guardedTimetableObject.eventList.indices.contains(index + 1)) {
                if (isActive(from: event.end, to: guardedTimetableObject.eventList[index + 1].start)) {
                    return "Du har rast just nu, \(guardedTimetableObject.eventList[index + 1].title) om \(TodayController.minutesToHourMinuteString(minutes: TodayController.getMinutesFromDates(from: self.currentDate, to: guardedTimetableObject.eventList[index + 1].start)))"
                }
            }
        }
        
        if (guardedTimetableObject.eventList.indices.contains(0)) {
            if (self.currentDate < guardedTimetableObject.eventList[0].start) {
                return "\(guardedTimetableObject.eventList[0].title) klockan \(Event.getHourMinuteString(date: guardedTimetableObject.eventList[0].start)) är första lektionen du har idag"
            }
        }
        return "Skoldagen är över"
    }
    
    /*func getDayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd/MM"
        formatter.locale =  Locale(identifier: "sv_SE")
        let dateString = formatter.string(from: currentDate)
        return dateString
    }*/
    
    
    func getCurrentWeek() -> Int {
        let calendar = NSCalendar.current
        let component = calendar.component(.weekOfYear, from: currentDate)
        return component
    }
    
    static func getDayNumberOfWeek(from: Date) -> Int {
        return from.dayNumberOfWeek()!
    }
    
    static func addDaysToCurrentDate(numberOfDays: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = numberOfDays
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        return futureDate!
    }
    
    func isActive(from: Date, to: Date) -> Bool {
        if from < to {
            return (from ... to).contains(currentDate)
        }
        return false
    }
    
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
}
