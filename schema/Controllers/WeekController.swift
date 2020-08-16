//
//  WeekController.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-20.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TimetableJsonWeekLoad {
    var timetableJson: JSON = []
    let week: Int
    let fetchError: FetchError?
}

class WeekController: ObservableObject {
    @Published var timetableJson: JSON = []
    @Published var timetableJsonWeekLoads: [TimetableJsonWeekLoad] = []
    @Published var fetchError: FetchError? = nil
    // @Published var selectedWeek: Int = 22
    @Published var targetSize: CGSize = CGSize(width: 400, height: 400)
    
    func load(profile: Profile?, ofWeek: Int) {
        self.fetchError = nil
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
                self.fetchAndSetObjectTimetable(selection: signature ?? "", selectionType: 4, ofWeek: ofWeek, profile: profile!, size: self.targetSize)
            }
            return
        }
        if (profile!.classGuid != nil) {
            fetchAndSetObjectTimetable(selection: profile!.classGuid!, selectionType: 0, ofWeek: ofWeek, profile: profile!, size: self.targetSize)
        }
        else if (profile!.teacherGuid != nil) {
            fetchAndSetObjectTimetable(selection: profile!.teacherGuid!, selectionType: 7, ofWeek: ofWeek, profile: profile!, size: self.targetSize)
        }
    }
    
    private func fetchAndSetObjectTimetable(selection: String, selectionType: Int, ofWeek: Int, profile: Profile, size: CGSize) {
        Skola24Wrapper.getTimetable(selection: selection, selectionType: selectionType, size: size, school: School(unitGuid: profile.schoolGuid ?? "", unitId: "Kungsfågeln", hostName: profile.domain ?? ""), week: ofWeek) { (timetableJson, fetchError) -> () in
            if (fetchError != nil) {
                // self.timetableJsonWeekLoads.append(TimetableJsonWeekLoad(timetableJson: nil, week: ofWeek, fetchError: fetchError))
                self.fetchError = fetchError
                return
            }
            if (timetableJson == nil) {
                // self.timetableJsonWeekLoads.append(TimetableJsonWeekLoad(timetableJson: nil, week: ofWeek, fetchError: FetchError(message: "Kunde inte bygga vecko-vyn")))
                self.fetchError = FetchError(message: "Kunde inte bygga vecko-vyn")
                return
            }
            // self.timetableJson = timetableJson!
            self.addTimetableJsonWeekLoad(timetableJsonWeekLoad: TimetableJsonWeekLoad(timetableJson: timetableJson!, week: ofWeek, fetchError: nil))
        }
    }
    
    func getTimetableJsonWeekLoad(ofWeek: Int) -> TimetableJsonWeekLoad? {
        for timetable in self.timetableJsonWeekLoads {
            if (timetable.week == ofWeek) {
                return timetable
            }
        }
        return nil
    }
    
    func setTimetableJsonWeekLoadFromWeek(week: Int, timetableJsonWeekLoad: TimetableJsonWeekLoad) {
        for var m_timetableJsonWeekLoad in self.timetableJsonWeekLoads {
            if (m_timetableJsonWeekLoad.week == timetableJsonWeekLoad.week) {
                m_timetableJsonWeekLoad = timetableJsonWeekLoad
            }
        }
    }
    
    func addTimetableJsonWeekLoad(timetableJsonWeekLoad: TimetableJsonWeekLoad) {
        if (getTimetableJsonWeekLoad(ofWeek: timetableJsonWeekLoad.week) == nil) {
            self.timetableJsonWeekLoads.append(timetableJsonWeekLoad)
            self.timetableJsonWeekLoads.sort {
                $0.week < $1.week
            }
        }
        else {
            setTimetableJsonWeekLoadFromWeek(week: timetableJsonWeekLoad.week, timetableJsonWeekLoad: timetableJsonWeekLoad)
        }
    }
    
    func getCurrentWeek() -> Int {
        let calendar = NSCalendar.current
        let component = calendar.component(.weekOfYear, from: Date())
        return component
    }
    
    /*
     Skola24Wrapper.getTimetable(selection: selection, selectionType: selectionType, school: School(unitGuid: profile.schoolGuid ?? "", unitId: "Kungsfågeln"), week: self.selectedWeek) { (eventList, fetchError) -> () in
     if (fetchError != nil) {
     self.fetchError = fetchError
     return
     }
     self.eventList = eventList
     }*/
}
