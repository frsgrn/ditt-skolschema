//
//  SchemaView.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-15.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import SwiftUI
import SwiftyJSON

struct SchemaView: View {
    @State private var selection = 0
    @EnvironmentObject var todayController: TodayController
    @EnvironmentObject var weekController: WeekController
    
    
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        TabView(selection: $selection){
            Group {
                TodayView(/*eventList: $todayController.eventList*/).environmentObject(todayController)
            }.tabItem {
                VStack {
                    Image(systemName: "rectangle.on.rectangle")
                    Text("Dagen")
                }
            }
            .tag(0)
            WeekView().tabItem {
                VStack {
                    Image(systemName: "calendar")
                    Text("Veckan")
                }
            }
            .tag(1)
            
            ProfileManagerView().tabItem {
                VStack {
                    Image(systemName: "list.bullet.below.rectangle")
                    Text("Scheman")
                }
            }
            .tag(2)
            
            SettingsView().tabItem {
                VStack {
                    Image(systemName: "gear")
                    Text("Inställningar")
                }
            }.tag(3)
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        }
        else {
            self
        }
    }
}

struct WeekView: View {
    @EnvironmentObject var weekController: WeekController
    @EnvironmentObject var todayController: TodayController
    
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var settings = UserSettings()
    /*
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
        let size = self.weekController.targetSize
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
    }*/
    
    @State private var selection = 0
    
    func foldWeek(week: Int) -> Int {
        if (week > 52) {
            return week - 52
        }
        else {
            return week
        }
    }
    
    func getSelectedWeek () -> Int {
        return self.foldWeek(week: self.weekController.getCurrentWeek() + self.selection)
    }
    
    var colors: [Color] = [.blue, .green, .red, .orange]
    
    
    
    /*
     HStack(alignment: .center, spacing: 30) {
         ForEach(0..<colors.count) { i in
             self.colors[i]
                  .frame(width: 250, height: 400, alignment: .center)
                  .cornerRadius(10)
         }
     }.modifier(ScrollingHStackModifier(items: colors.count, itemWidth: 250, itemSpacing: 30, onEnded: { index in
         print(index)
     }))
     */
    
    
    var body: some View {
        NavigationView {
        ZStack {
            VStack {
                
                        VStack {
                        if (self.weekController.getTimetableJsonWeekLoad(ofWeek: self.getSelectedWeek()) != nil) {
                            Image(uiImage: self.weekController.getTimetableJsonWeekLoad(ofWeek: self.getSelectedWeek())!.uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .pinchToZoom()
                                .if(self.colorScheme == .dark && self.settings.invertSchemaColor) { view in
                                    view.colorInvert()
                                }
                            .frame(width: UIScreen.main.bounds.width)
                        }
                        else {
                            VStack {
                                Spacer()
                                HStack(alignment: .center) {
                                    Spacer()
                                    Spinner(isAnimating: true, style: .medium, color: .gray)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        }
                
                /*
                VStack {
                if (self.weekController.getTimetableJsonWeekLoad(ofWeek: self.getSelectedWeek()) != nil) {
                    Image(uiImage: self.drawTimetable(timetableJson: self.weekController.getTimetableJsonWeekLoad(ofWeek: self.getSelectedWeek())!.timetableJson))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .pinchToZoom()
                        .if(self.colorScheme == .dark && self.settings.invertSchemaColor) { view in
                            view.colorInvert()
                        }
                }
                else {
                    VStack {
                        Spacer()
                        HStack(alignment: .center) {
                            Spacer()
                            Spinner(isAnimating: true, style: .medium, color: .gray)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                }.padding(15)
 
 */
                
                
                
                Spacer()
                HorizontalWeekPicker(selection: self.$selection)
            }
        }.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)).navigationBarTitle("Vecka \(self.getSelectedWeek())", displayMode: .inline)
        }.navigationViewStyle(StackNavigationViewStyle())
        
    }
}

/*struct WeekViewDayInsight: View {
    let date: Date
    var body: some View {
        ScrollView {
            SchemaCardStack(date: date)
        }.navigationBarTitle("dagvy")
    }
}*/

struct HorizontalWeekPicker: View {
    @Binding var selection: Int
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @EnvironmentObject var weekController: WeekController
    
    func foldWeek(week: Int) -> Int {
        if (week > 52) {
            return week - 52
        }
        else {
            return week
        }
    }
    
    func getSelectedWeek () -> Int {
        return self.getWeekFromSelection(s: self.selection)
    }
    
    func getWeekFromSelection (s: Int) -> Int {
        return self.foldWeek(week: self.weekController.getCurrentWeek() + s)
    }
    
    func getCircleBackgroundColor(index: Int) -> Color {
        if (self.getSelectedWeek() == self.getWeekFromSelection(s: index)) {
            if (index != 0) {
                return Color(UIColor.label)
            }
            else {
                return Color(UIColor.systemPink)
            }
        }
        else {
            return Color(UIColor.tertiarySystemGroupedBackground)
        }
    }
    
    func getForegroundColor(index: Int) -> Color {
        if (self.getSelectedWeek() == self.getWeekFromSelection(s: index)) {
            return Color(UIColor.systemBackground)
        }
        else if (index == 0) {
            return Color(UIColor.systemPink)
        }
        else {
            return Color(UIColor.label)
        }
    }
    
    func isBold(index: Int) -> Bool {
        return self.getSelectedWeek() == self.getWeekFromSelection(s: index)
    }
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false){
            HStack {
                ForEach(0...51, id: \.self) { index2 in
                    Button(action: {
                        print(index2)
                        self.selection = index2
                        let profile = self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")})
                        self.weekController.load(profile: profile, ofWeek: self.getSelectedWeek())
                    }) {
                    HStack {
                        Text("vecka").padding([.leading], 10).foregroundColor(Color(UIColor.label))
                        Text("\(self.foldWeek(week: self.weekController.getCurrentWeek() + index2))")
                            .if(self.isBold(index: index2)) { view in
                                view.bold()
                        }
                        .frame(width: 35, height: 35)
                            //.background(Color(UIColor.tertiarySystemGroupedBackground))
                            .background(self.getCircleBackgroundColor(index: index2))
                            .foregroundColor(self.getForegroundColor(index: index2))
                        .clipShape(Circle())
                        }.padding(5).background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(30)
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15)).onAppear {
                let profile = self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")})
                self.weekController.load(profile: profile, ofWeek: self.getSelectedWeek())
            }
        }
    }
}

struct TodayView: View {
    //@Binding var eventList: [Event]
    @EnvironmentObject var todayController: TodayController
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack {
                    HorizontalDatePicker(dateNumberLimit: 14).padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    VStack {
                    Text("\(todayController.assistantMessage())")
                        .font(.system(size: 20)).bold().multilineTextAlignment(.center)
                    }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 13, trailing: 0))//.background(Color("DatePickerBackground"))
                VStack {
                    if (self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate) != nil) {
                        if (self.todayController.getSelectedEventList().count > 0) {
                            ScrollView {
                                SchemaCardStack(date: self.todayController.selectedDate).padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
                            }
                        }
                        else if (self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate)!.fetchError != nil) {
                            Text(self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate)!.fetchError!.message).foregroundColor(Color(UIColor.red)).padding()
                            Spacer()
                        }
                        else {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("☕️").font(.system(size: 40))
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    else {
                        Spacer()
                        HStack {
                            Spacer()
                            Spinner(isAnimating: true, style: .medium, color: .gray).padding()
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
            }.background(Color(UIColor.systemGroupedBackground)).navigationBarTitle("Dagen", displayMode: .inline)
            //.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct EventDetailView : View {
    let event: Event
    var body: some View {
        List {
            Section(header: Text("Tidsram"), footer: Text("Det finns alltid en risk att appen läser av ditt schema felaktigt eller att det har skett en schemaändring som inte visas i Skola24 systemet.")) {
                HStack {
                    Text("Börjar")
                    Spacer()
                    Text(event.start.localString())
                }
                HStack {
                    Text("Slutar")
                    Spacer()
                    Text(event.end.localString())
                }
                HStack {
                    Text("Längd")
                    Spacer()
                    Text(TodayController.minutesToHourMinuteString(minutes: TodayController.getMinutesFromDates(from: event.start, to: event.end)))
                }
            }
            Section(header: Text("Mer information om lektionen")) {
                Text(event.information)
            }
            
        }.listStyle(GroupedListStyle()).navigationBarTitle(Text(event.title), displayMode: .inline)
    }
}

struct HorizontalDatePicker : View {
    
    @EnvironmentObject var todayController: TodayController
    @State var dateNumberLimit: Int
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    
    func getDayNameOfDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        dateFormatter.locale =  Locale(identifier: "sv_SE")
        let dayInWeek = dateFormatter.string(from: date)
        return dayInWeek
    }
    
    func getDayOfDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let dayInWeek = dateFormatter.string(from: date)
        return dayInWeek
    }
    
    func addDaysToCurrentDate(num: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = num
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: self.todayController.currentDate)
        return futureDate!
    }
    
    func isOnSameDay(date: Date, date2: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs:date2)
    }
    
    func getCircleBackgroundColor(index: Int) -> Color {
        if (self.isOnSameDay(date: self.todayController.selectedDate, date2: self.addDaysToCurrentDate(num: index))) {
            if (index != 0) {
                return Color(UIColor.label)
            }
            else {
                return Color(UIColor.systemPink)
            }
        }
        else {
            return Color(UIColor.white).opacity(0)
        }
    }
    
    func getDateForegroundColor(index: Int) -> Color {
        if (self.isOnSameDay(date: self.todayController.selectedDate, date2: self.addDaysToCurrentDate(num: index))) {
            return Color(UIColor.systemBackground)
        }
        else if (index == 0) {
            return Color(UIColor.systemPink)
        }
        else {
            return Color(UIColor.label)
        }
    }
    
    func isBold(index: Int) -> Bool {
        return self.isOnSameDay(date: self.todayController.selectedDate, date2: self.addDaysToCurrentDate(num: index))
    }
    
    var body: some View {
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<dateNumberLimit) { index in
                    Button(action: {
                        self.todayController.selectedDate = self.addDaysToCurrentDate(num: index)
                        self.todayController.load(profile: self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")}))
                    }) {
                        VStack {
                            Text(self.getDayNameOfDate(date: self.addDaysToCurrentDate(num: index)))
                                .font(.caption)
                                .frame(width: 40)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Text(self.getDayOfDate(date: self.addDaysToCurrentDate(num: index)))
                                .fontWeight(self.isBold(index: index) ? .bold : .regular)
                                .frame(width: 40, height: 40)
                                .background(self.getCircleBackgroundColor(index: index))
                                .foregroundColor(self.getDateForegroundColor(index: index))
                                .clipShape(Circle())
                        }.padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)).onAppear {
                self.todayController.load(profile: self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")}))
            }
        }
    }
}

struct SchemaCardStack: View {
    @EnvironmentObject var todayController: TodayController
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>

    @State var date: Date
    
    func getEventList() -> [Event] {
        
        guard let eventList = todayController.getTimetableObjectLoadFromDate(date: self.date) else {
            return []
        }
        return eventList.eventList
        
        /*if (todayController.getTimetableObjectLoadFromDate(date: self.date) == nil) {
            return []
        }
        else {
            return todayController.getTimetableObjectLoadFromDate(date: self.date)!.eventList
        }*/
    }
    
    /*var body: some View {
        VStack {
            ForEach(self.todayController.getSelectedEventList().indices, id: \.self) { index in
                Group {
                    NavigationLink(destination: EventDetailView(event: self.todayController.getSelectedEventList()[index])) {
                        SchemaCard(event: self.todayController.getSelectedEventList()[index])
                    }
                    if (self.todayController.getSelectedEventList().indices.contains(index + 1)) {
                        if (self.shouldUseRecess(end: self.todayController.getSelectedEventList()[index].end, start: self.todayController.getSelectedEventList()[index + 1].start)) {
                            Recess(previous: self.todayController.getSelectedEventList()[index], next: self.todayController.getSelectedEventList()[index + 1])
                        }
                        else {
                            Spacer()
                        }
                    }
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 15, bottom: 45, trailing: 15))
    }*/
    
    var body: some View {
        VStack {
            ForEach(getEventList().indices, id: \.self) { index in
                Group {
                    NavigationLink(destination: EventDetailView(event: self.getEventList()[index])) {
                        SchemaCard(event: self.getEventList()[index])
                    }
                    if (self.getEventList().indices.contains(index + 1)) {
                        if (self.shouldUseRecess(end: self.getEventList()[index].end, start: self.getEventList()[index + 1].start)) {
                            Recess(previous: self.getEventList()[index], next: self.getEventList()[index + 1])
                        }
                        else {
                            Spacer()
                        }
                    }
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 15, bottom: 45, trailing: 15))
    }
    
    func shouldUseRecess(end: Date, start: Date) -> Bool {
        if (TodayController.getMinutesFromDates(from: end, to: start) > 0) {
            return true
        }
        return false
    }
}


struct SchemaCard: View {
    let event: Event
    @EnvironmentObject var todayDelegate: TodayController
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 5) {
                if (self.todayDelegate.isActive(from: event.start, to: event.end)) {
                    HStack {
                        Text("Just nu").bold()
                    }.font(.footnote).foregroundColor(Color(UIColor.systemBlue))
                }
                Text(event.title).font(.headline)
                HStack (alignment: .center) {
                    Text(Event.getHourMinuteString(date: event.start))
                    Image(systemName: "minus")
                    Text(Event.getHourMinuteString(date: event.end))
                }.font(.callout)
                if (event.information.count > 0) {
                    Text(event.information).font(.callout)
                }
            }
            Spacer()
        }.foregroundColor(self.todayDelegate.isActive(from: event.start, to: event.end) ? Color(UIColor.label) : Color(UIColor.secondaryLabel)
        ).padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(10)
    }
}

struct Recess: View {
    let previous: Event
    let next: Event
    
    @EnvironmentObject var todayDelegate: TodayController
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.down")
            Text("rast i \(TodayController.minutesToHourMinuteString(minutes: TodayController.getMinutesFromDates(from: previous.end, to: next.start)))").font(.footnote)
        }.foregroundColor(self.todayDelegate.isActive(from: previous.end, to: next.start) ? Color(UIColor.systemBlue) : Color(UIColor.secondaryLabel)).padding(.bottom, 2)
    }
}

struct SchemaView_Previews: PreviewProvider {
    static var previews: some View {
        SchemaView()
    }
}
