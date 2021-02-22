//
//  Skola24Wrapper.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-12.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import SwiftUI
import Alamofire
import SwiftyJSON

struct Domain {
    let name: String
    let url: String
    let id: UUID = UUID()
}

struct s24_Class {
    let id = UUID()
    let name: String
    let groupGuid: String
}

struct Teacher {
    let uuid = UUID()
    let firstName: String
    let lastName: String
    let id: String
    let personGuid: String
}

struct School {
    let id: UUID = UUID()
    let unitGuid: String
    let unitId: String
    let hostName: String
}

struct Selection {
    let teacher: Teacher? = nil
    let s24_class: s24_Class? = nil
    let signature: String? = nil
}

struct Event : Identifiable {
    var id = UUID().uuidString
    var start: Date
    var hasStart = false
    var end: Date
    var hasEnd = false
    var title: String
    var information: String
    var x: Int = -1
    var y: Int = -1
    var width: Int = -1
    var height: Int = -1
    
    // var color: UIColor = UIColor.blue
    
    static func getHourMinuteString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct Timeframe {
    let start: Date
    let end: Date
    let dayOfWeek: Int
    static func formatDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T00:00:00'"
        let dateString = formatter.string(from: date)
        return dateString
    }
}

class Skola24Wrapper{
    
    static let headers: HTTPHeaders = [
        "Cookie": "ASP.NET_SessionId=ikj2emwf3rd10b2v1dy212c0; ASP.NET_SessionId=mbawd5bm2q4g2smpjc1dccre",
        "Host": "web.skola24.se",
        "X-Scope": "8a22163c-8662-4535-9050-bc5e1923df48"
    ]
    
    static func getSignature(userId: String, completion: @escaping (String?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/encrypt/signature", method: .post, parameters: JSON(["signature": userId]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                let json = try JSON(data: response.data!)
                completion(json["data"]["signature"].rawString()!, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta signatur"))
            }
        }
    }
    
    static func getSchools(hostName: String, completion: @escaping ([School]?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/services/skola24/get/timetable/viewer/units", method: .post, parameters: JSON(["getTimetableViewerUnitsRequest": ["hostName": hostName]]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                var foundUnits: [School] = []
                let json = try JSON(data: response.data!)
                for (_, subJSON) in json["data"]["getTimetableViewerUnitsResponse"]["units"] {
                    foundUnits.append(School(unitGuid: subJSON["unitGuid"].rawString()!, unitId: subJSON["unitId"].rawString()!, hostName: hostName))
                }
                completion(foundUnits, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta skolor"))
            }
        }
    }
    
    static func getClasses(school: School, completion: @escaping ([s24_Class]?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/get/timetable/selection", method: .post, parameters: JSON(["hostName": school.hostName, "unitGuid": school.unitGuid, "filters": ["class": true, "course": false, "group": false, "period": false, "room": false, "student": false, "subject": false, "teacher": false]]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                let json = try JSON(data: response.data!)
                var classList: [s24_Class] = []
                for val in json["data"]["classes"].arrayValue {
                    classList.append(s24_Class(name: val["groupName"].rawString()!, groupGuid: val["groupGuid"].rawString()!))
                }
                completion(classList, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta klasser"))
            }
        }
    }
    
    static func getTeachers(school: School, completion: @escaping ([Teacher]?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/get/timetable/selection", method: .post, parameters: JSON(["hostName": school.hostName, "unitGuid": school.unitGuid, "filters": ["class": false, "course": false, "group": false, "period": false, "room": false, "student": false, "subject": false, "teacher": true]]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                let json = try JSON(data: response.data!)
                var teacherList: [Teacher] = []
                for val in json["data"]["teachers"].arrayValue {
                    teacherList.append(Teacher(firstName: val["firstName"].rawString()!, lastName: val["lastName"].rawString()!, id: val["id"].rawString()!, personGuid: val["personGuid"].rawString()!))
                }
                completion(teacherList, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta lärare"))
            }
        }
    }
    
    static func calculateYear(week: Int) -> Int {
        if (week < DateExtensions.getWeekFrom(date: Date())) {
            return Calendar.current.component(.year, from: Date()) + 1
        }
        else {
            return Calendar.current.component(.year, from: Date())
        }
    }
    
    static func getTimetable(selection: String, selectionType: Int, size: CGSize, school: School, week: Int, completion: @escaping((JSON?, FetchError?) -> ())) {
        
        getRenderKey() { (key, fetchError) in
            if (fetchError != nil) {
                completion(nil, fetchError)
                return
            }
            else if(key == nil) {
                completion(nil, FetchError(message: "Kunde inte ladda nyckeln"))
            }
            print("week")
            print(week)
            AF.request("https://web.skola24.se/api/render/timetable", method: .post, parameters: JSON([
                "selection": selection,
                "unitGuid": school.unitGuid,
                "selectionType": selectionType,
                "blackAndWhite": false,
                "startDate": JSON.null,
                "endDate": JSON.null,
                "height": size.height,
                "width": size.width,
                "renderKey": key,
                "customerKey": "",
                "privateSelectionMode": false,
                "privateFreeTextMode": false,
                "host": school.hostName,
                "periodText": "",
                "privateMode": JSON.null,
                "scheduleDay": 0,
                "showHeader": false,
                "week": week,
                "year": calculateYear(week: week)
            ]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
                do {
                    if (response.data == nil) {
                        throw NSError()
                    }
                    let json = try JSON(data: response.data!)
                    // let rawTimetableString = json["data"]["timetableJson"].rawString()
                    let rawTimetableString = json["data"].rawString()
                    let strData = rawTimetableString!.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    let jsonData: JSON = try JSON(data: strData!)
                    print(jsonData)
                    completion(jsonData, nil)
                } catch {
                    print(error)
                    completion(nil, FetchError(message: "Kunde inte hämta vecka"))
                }
            }
            
        }
    }
    
    static func getRenderKey(completion: @escaping (String?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/get/timetable/render/key", method: .post, parameters: JSON([
            JSON.null
        ]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                let json = try JSON(data: response.data!)
                
                let key = json["data"]["key"]
                completion(key.stringValue, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta renderingsnyckel"))
            }
        }
    }
    
    static func getObjectTimetable(selection: String, selectionType: Int, school: School, timeframe: Timeframe, selectedDate: Date, completion: @escaping ([Event], FetchError?) -> ()) {
        getRenderKey() { (key, fetchError) in
            if (fetchError != nil) {
                completion([], fetchError)
                return
            }
            else if(key == nil) {
                completion([], FetchError(message: "Kunde inte ladda nyckeln"))
            }
            AF.request("https://web.skola24.se/api/render/timetable", method: .post, parameters: JSON([
                "selection": selection,
                "unitGuid": school.unitGuid,
                "selectionType": selectionType,
                "blackAndWhite": false,
                "startDate": Timeframe.formatDateToString(date: timeframe.start),
                "endDate": Timeframe.formatDateToString(date: timeframe.end),
                "height": 700,
                "width": 1200,
                "renderKey": key,
                "host": school.hostName,
                "periodText": "Period text",
                "privateMode": false,
                "scheduleDay": timeframe.dayOfWeek,
                "showHeader": false,
                "week": JSON.null
            ]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
                // print(response)
                do {
                    if (response.data == nil) {
                        throw NSError()
                    }
                    let json:JSON = try JSON(data: response.data!)
                    let rawTimetableString = json["data"].rawString()
                    let strData = rawTimetableString!.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    let lessonList: JSON = try JSON(data: strData!)["lessonInfo"]
                    var eventList: [Event] = []
                    for lesson in lessonList {
                        print(lesson)
                        let texts = lesson.1["texts"]
                        let timeStart = DateExtensions.newDateFromHourMinuteString(hourMinuteString: "" + lesson.1["timeStart"].stringValue.split(separator: ":")[0] + ":" + lesson.1["timeStart"].stringValue.split(separator: ":")[1], from: selectedDate)
                        
                        let timeEnd = DateExtensions.newDateFromHourMinuteString(hourMinuteString: "" + lesson.1["timeEnd"].stringValue.split(separator: ":")[0] + ":" + lesson.1["timeEnd"].stringValue.split(separator: ":")[1], from: selectedDate)
                        
                        var information = ""
                        for (index, element) in texts.arrayValue.enumerated() {
                            if (index != 0) {
                                information = information + " " + element.stringValue
                            }
                        }
                        
                        information = information.trimmingCharacters(in: [" "])
                        
                        let working = Event(start: timeStart, end: timeEnd, title: texts[0].stringValue, information: information)
                        eventList.append(working)
                    }
                    eventList = eventList.sorted {
                        $0.start < $1.start
                    }
                    completion(eventList, nil)
                } catch {
                    completion([], FetchError(message: "Kunde bygga idag-vy"))
                }
                /*do {
                    if (response.data == nil) {
                        throw NSError()
                    }
                    let json:JSON = try JSON(data: response.data!)
                    //let rawTimetableString = json["data"]["timetableJson"].rawString()
                    let rawTimetableString = json["data"].rawString()
                    
                    let strData = rawTimetableString!.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    print(strData)
                    let timetable: JSON = try JSON(data: strData!)["textList"]
                    let boxList: JSON = try JSON(data: strData!)["boxList"]
                    
                    var filteredBoxList = boxList.arrayValue.filter {$0["height"] > 22 && $0["width"] > 100 && $0["y"] != 0 && $0["bcolor"] != "#CCCCCC"}
                    filteredBoxList.remove(at: 0)
                    
                    
                    let filteredTimetable = timetable.arrayValue.filter {$0["text"] != ""}
                    
                    var sortedTimetable = filteredTimetable.sorted { u1, u2 in
                        return (u1["y"], u1["x"]) < (u2["y"], u2["x"])
                    }
                    
                    sortedTimetable.removeFirst(1)
                    var eventList: [Event] = []
                    
                    let timeRegex = #"^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]"#
                    
                    for box in filteredBoxList {
                        var working: Event = Event(start: Date(), end: Date(), title: "", information: "")
                        var startDateY = -1
                        var endDateY = -1
                        
                        working.x = box["x"].intValue
                        working.y = box["y"].intValue
                        working.width = box["width"].intValue
                        working.height = box["height"].intValue
                        
                        working.color = ColorExtensions.hexStringToUIColor(hex: box["bcolor"].stringValue)
                        
                        for drawText in sortedTimetable {
                            if (box["x"].intValue <= drawText["x"].intValue && drawText["x"].intValue <= box["x"].intValue + box["width"].intValue && box["y"].intValue - 10 <= drawText["y"].intValue && drawText["y"].intValue <= box["y"].intValue + box["height"].intValue) {
                                if (drawText["text"].rawString()?.range(of: timeRegex, options: .regularExpression) != nil) {
                                    if (drawText["x"].intValue == box["x"].intValue + 1 && startDateY == -1) {
                                        startDateY = drawText["y"].intValue
                                        working.start = DateExtensions.newDateFromHourMinuteString(hourMinuteString: drawText["text"].rawString()!, from: selectedDate)
                                        working.hasStart = true
                                        continue
                                    }
                                    else if (drawText["x"].intValue > box["x"].intValue + 5) {
                                        endDateY = drawText["y"].intValue
                                        working.end = DateExtensions.newDateFromHourMinuteString(hourMinuteString: drawText["text"].rawString()!, from: selectedDate)
                                        working.hasEnd = true
                                        continue
                                    }
                                    continue
                                }
                                if (working.title == "") {
                                    working.title = drawText["text"].rawString()!
                                    continue
                                }
                                working.information = working.information + " " + drawText["text"].rawString()!
                                working.information = working.information.trimmingCharacters(in: [" "])
                            }
                        }
                        eventList.append(working)
                    }
                    
                    for index in 0..<eventList.count {
                        if (!eventList[index].hasStart) {
                            for event2 in eventList {
                                if (event2.hasStart && eventList[index].y == event2.y) {
                                    eventList[index].start = event2.start
                                    eventList[index].hasStart = true
                                    break
                                }
                            }
                        }
                        if (!eventList[index].hasEnd) {
                            for event2 in eventList {
                                if (event2.hasEnd && eventList[index].y + eventList[index].height == event2.y + event2.height) {
                                    eventList[index].end = event2.end
                                    eventList[index].hasEnd = true
                                    break
                                }
                            }
                        }
                    }
                    /*eventList = eventList.filter {!$0.title.lowercased().contains("lunch")}*/
                    eventList = eventList.sorted {
                        $0.start < $1.start
                    }
                    
                    for var event in eventList {
                        event.id = event.title + event.start.localString(dateStyle: .long, timeStyle: .full)
                    }
                    
                    completion(eventList, nil)
                } catch {
                    completion([], FetchError(message: "Kunde bygga idag-vy"))
                }*/
            }
        }
    }
}
