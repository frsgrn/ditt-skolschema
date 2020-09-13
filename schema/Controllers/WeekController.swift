//
//  WeekController.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-20.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftyJSON

struct TimetableJsonWeekLoad {
    var timetableJson: JSON = []
    let week: Int
    let fetchError: FetchError?
    let uiImage: UIImage
}

class WeekController: ObservableObject {
    @Published var timetableJson: JSON = []
    @Published var timetableJsonWeekLoads: [TimetableJsonWeekLoad] = []
    @Published var fetchError: FetchError? = nil
    @Published var targetSize: CGSize = CGSize(width: 600 * 1.5, height: 600 * 1.5 * 1.41428571429)
    
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
                self.fetchError = fetchError
                return
            }
            if (timetableJson == nil) {
                self.fetchError = FetchError(message: "Kunde inte bygga vecko-vyn")
                return
            }
            self.addTimetableJsonWeekLoad(timetableJsonWeekLoad: TimetableJsonWeekLoad(timetableJson: timetableJson!, week: ofWeek, fetchError: nil, uiImage: self.drawTimetable(timetableJson: timetableJson!)))
        }
    }
    
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.orange
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func drawTimetable(timetableJson: JSON) -> UIImage {
        print("drawcall")
        let size = self.targetSize
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            var sortedTimetable = timetableJson["boxList"].arrayValue
            sortedTimetable.sort {
                Int($0["type"].stringValue)! > Int($1["type"].stringValue)!
            }
            for text in sortedTimetable {
                ctx.cgContext.setStrokeColor(hexStringToUIColor(hex: text["fcolor"].stringValue).cgColor)
                ctx.cgContext.setFillColor(hexStringToUIColor(hex: text["bcolor"].stringValue).cgColor)
                ctx.cgContext.addRect(CGRect(x: text["x"].int!, y: text["y"].int!, width: text["width"].int!, height: text["height"].int!))
                ctx.cgContext.drawPath(using: .fillStroke)
            }
            
            for text in timetableJson["textList"].arrayValue {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: (text["bold"].boolValue ? UIFont.boldSystemFont(ofSize: CGFloat(text["fontsize"].floatValue)) : UIFont.systemFont(ofSize: CGFloat(text["fontsize"].floatValue))),
                    .paragraphStyle: paragraphStyle,
                    .foregroundColor: hexStringToUIColor(hex: text["fcolor"].stringValue)
                ]
                
                let string = text["text"].stringValue
                let attributedString = NSAttributedString(string: string, attributes: attrs)
                attributedString.draw(with: CGRect(x: CGFloat(text["x"].int!), y: CGFloat(text["y"].int!), width: attributedString.size().width, height: attributedString.size().height), options: .usesLineFragmentOrigin, context: nil)
            }
        }
        
        return img
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
        return WeekController.getWeekFrom(date: Date())
    }
    
    static func getWeekFrom(date: Date) -> Int {
        let calendar = NSCalendar.current
        let component = calendar.component(.weekOfYear, from: date)
        return component
    }
}
