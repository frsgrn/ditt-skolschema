//
//  SchemaView.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-15.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import SwiftUI
import SwiftyJSON

class PinchZoomView: UIView {
    
    weak var delegate: PinchZoomViewDelgate?
    
    private(set) var scale: CGFloat = 0 {
        didSet {
            delegate?.pinchZoomView(self, didChangeScale: scale)
        }
    }
    
    private(set) var anchor: UnitPoint = .center {
        didSet {
            delegate?.pinchZoomView(self, didChangeAnchor: anchor)
        }
    }
    
    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchZoomView(self, didChangeOffset: offset)
        }
    }
    
    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchZoomView(self, didChangePinching: isPinching)
        }
    }
    
    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0
    
    init() {
        super.init(frame: .zero)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches
            
        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
                
                numberOfTouches = gesture.numberOfTouches
            }
            
            scale = gesture.scale
            
            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
            
        case .ended, .cancelled, .failed:
            isPinching = false
            scale = 1.0
            anchor = .center
            offset = .zero
        default:
            break
        }
    }
    
}

protocol PinchZoomViewDelgate: AnyObject {
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

struct PinchZoom: UIViewRepresentable {
    
    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView()
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }
    
    func updateUIView(_ pageControl: PinchZoomView, context: Context) { }
    
    class Coordinator: NSObject, PinchZoomViewDelgate {
        var pinchZoom: PinchZoom
        
        init(_ pinchZoom: PinchZoom) {
            self.pinchZoom = pinchZoom
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
            pinchZoom.anchor = anchor
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }
}

struct PinchToZoom: ViewModifier {
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .animation(isPinching ? .none : .spring())
            .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
    }
}

extension View {
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
}


struct SchemaView: View {
    @State private var selection = 0
    @EnvironmentObject var todayController: TodayController
    @EnvironmentObject var weekController: WeekController
    
    
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        TabView(selection: $selection){
            Group {
                TodayView(eventList: $todayController.eventList).environmentObject(todayController)
            }.tabItem {
                VStack {
                    Image(systemName: "rectangle.on.rectangle")
                    Text("Idag")
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
            
            NavigationView {ProfileManagerView()}.tabItem {
                VStack {
                    Image(systemName: "list.bullet.below.rectangle")
                    Text("Scheman")
                }
            }
            .tag(2)
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
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @Environment(\.colorScheme) var colorScheme
    
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
    
    func foldWeek(week: Int) -> Int {
        if (week > 52) {
            return week - 52
        }
        else {
            return week
        }
    }
    
    func drawTimetable(timetableJson: JSON) -> UIImage {
        let size = self.weekController.targetSize
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            var sortedTimetable = timetableJson["boxList"].arrayValue
            sortedTimetable.sort {
                Int($0["type"].stringValue)! > Int($1["type"].stringValue)!
            }
            for text in sortedTimetable {
                // if (text["type"].stringValue == "4") {
                ctx.cgContext.setStrokeColor(hexStringToUIColor(hex: text["fcolor"].stringValue).cgColor)
                // ctx.cgContext.setFillColor(UIColor.systemGroupedBackground.cgColor)
                ctx.cgContext.setFillColor(hexStringToUIColor(hex: text["bcolor"].stringValue).cgColor)
                ctx.cgContext.addRect(CGRect(x: text["x"].int!, y: text["y"].int!, width: text["width"].int!, height: text["height"].int!))
                ctx.cgContext.drawPath(using: .fillStroke)
                // }
            }
            
            
            /*
             
             for text in timetableJson["boxList"].arrayValue {
             if (text["type"].stringValue == "3") {
             ctx.cgContext.setFillColor(UIColor.systemGroupedBackground.cgColor)
             ctx.cgContext.addRect(CGRect(x: text["x"].int!, y: text["y"].int!, width: text["width"].int!, height: text["height"].int!))
             }
             }
             ctx.cgContext.drawPath(using: .fill)
             */
            
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
    
    @State private var selection = 0
    @State private var oldSelection = 0
    @State private var hasLoadedFirstTime = false
    @State private var lastUsedProfile: Profile? = nil
    
    private var standardWeekNumLimit = 4
    
    let spacing: CGFloat = 20
    
    func getSelectedWeek () -> Int {
        return self.foldWeek(week: self.weekController.getCurrentWeek() + self.selection)
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                    Group {
                        if (self.weekController.getTimetableJsonWeekLoad(ofWeek: self.getSelectedWeek()) != nil) {
                            ScrollView {
                                Group {
                                    HStack {
                                        Text("Vecka \(self.getSelectedWeek())").font(.title).bold()
                                        Spacer()
                                    }
                                    Image(uiImage: self.drawTimetable(timetableJson: self.weekController.getTimetableJsonWeekLoad(ofWeek: self.getSelectedWeek())!.timetableJson))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .pinchToZoom()
                                    .if(self.colorScheme == .dark) { view in
                                        view.colorInvert()
                                    }
                                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                                
                            }
                        }
                        else {
                            Spacer()
                            HStack(alignment: .center) {
                                Spacer()
                                Text("Laddar...")
                                Spacer()
                            }
                        }
                        
                    }
                
                Spacer()
                HStack {
                    Button(action: {
                            self.selection -= 1
                        
                    }) {
                        Image(systemName: "calendar.badge.minus")
                    }.padding()
                    Spacer()
                    Picker("Vecka", selection: $selection) {
                        if (self.selection < 0) {
                            Text("\(self.foldWeek(week: self.weekController.getCurrentWeek() + selection))").tag(self.selection)
                        }
                        ForEach(0 ..< self.standardWeekNumLimit) { index in
                            HStack {
                                Text("\(self.foldWeek(week: self.weekController.getCurrentWeek() + index))")
                            }.tag(index)
                        }
                        if (self.selection >= self.standardWeekNumLimit) {
                            Text("\(self.foldWeek(week: self.weekController.getCurrentWeek() + selection))").tag(self.selection)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onReceive([selection].publisher.first()) { (value) in
                        if (self.oldSelection != value || !self.hasLoadedFirstTime) {
                            print("\(value)")
                            let profile = self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")})
                            self.weekController.load(profile: profile, ofWeek: self.foldWeek(week: self.weekController.getCurrentWeek() + value))
                            self.oldSelection = value
                            self.hasLoadedFirstTime = true
                        }
                    }
                    
                    Spacer()
                    Button(action: {
                            self.selection += 1
                    }) {
                        Image(systemName: "calendar.badge.plus")
                    }.padding()
                }
                
                
                
            }.padding(15)
        }.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)).onAppear {
            if (self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")}) != self.lastUsedProfile) {
                self.weekController.timetableJsonWeekLoads = []
                self.hasLoadedFirstTime = false
                self.lastUsedProfile = self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")})
            }
        }
    }
}

struct TodayView: View {
    @Binding var eventList: [Event]
    @EnvironmentObject var todayController: TodayController
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HorizontalDatePicker(dateNumberLimit: 14).padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                VStack(alignment: .leading) {
                    Text("\(todayController.assistantMessage())")
                        .font(.system(size: 20)).bold()
                }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                if (self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate) != nil) {
                    if (self.todayController.getSelectedEventList().count > 0) {
                        ScrollView(.vertical) {
                            SchemaCardStack()
                        }
                    }
                    else if (self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate)!.fetchError != nil) {
                        Text(self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate)!.fetchError!.message).foregroundColor(Color(UIColor.red)).padding()
                        Spacer()
                    }
                    else {
                        Text("Ingenting för idag, se fliken \"Veckan\" för en översikt.").padding()
                        Spacer()
                    }
                }
                else {
                    Text("Vänta tills appen har läst in ditt schema...").padding()
                    Spacer()
                }
                
                
            }
        }.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
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
                return Color(UIColor.black)
            }
            else {
                return Color(UIColor.systemRed)
            }
        }
        /*else if (index == 0) {
            return Color(UIColor.systemGray5)
        }*/
        else {
            return Color(UIColor.white).opacity(0)
        }
    }
    
    func getDateForegroundColor(index: Int) -> Color {
        if (self.isOnSameDay(date: self.todayController.selectedDate, date2: self.addDaysToCurrentDate(num: index))) {
            return Color(UIColor.white)
        }
        else if (index == 0) {
            return Color(UIColor.systemRed)
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
    //@Binding var eventList: [Event]
    @EnvironmentObject var todayController: TodayController
    var body: some View {
        VStack {
            ForEach(self.todayController.getSelectedEventList().indices, id: \.self) { index in
                Group {
                    SchemaCard(event: self.todayController.getSelectedEventList()[index])
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
        }.padding(EdgeInsets(top: 0, leading: 15, bottom: 25, trailing: 15))
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
