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
        }.onAppear {
            self.todayController.load(profile: self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")}))
            
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
            
            for text in timetableJson["boxList"].arrayValue {
                if (text["type"].stringValue == "4") {
                    ctx.cgContext.setStrokeColor(UIColor.secondaryLabel.cgColor)
                    ctx.cgContext.setFillColor(UIColor.systemGroupedBackground.cgColor)
                    ctx.cgContext.addRect(CGRect(x: text["x"].int!, y: text["y"].int!, width: text["width"].int!, height: text["height"].int!))
                }
            }
            ctx.cgContext.drawPath(using: .fillStroke)
            
            
            for text in timetableJson["boxList"].arrayValue {
                if (text["type"].stringValue == "3") {
                    ctx.cgContext.setFillColor(UIColor.systemGroupedBackground.cgColor)
                    ctx.cgContext.addRect(CGRect(x: text["x"].int!, y: text["y"].int!, width: text["width"].int!, height: text["height"].int!))
                }
            }
            ctx.cgContext.drawPath(using: .fill)
            
            
            
            
            
            
            for text in timetableJson["textList"].arrayValue {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: (text["bold"].boolValue ? UIFont.boldSystemFont(ofSize: CGFloat(text["fontsize"].floatValue)) : UIFont.systemFont(ofSize: CGFloat(text["fontsize"].floatValue))),
                    .paragraphStyle: paragraphStyle,
                    .foregroundColor: UIColor.label//hexStringToUIColor(hex: text["fcolor"].stringValue)
                ]
                
                let string = text["text"].stringValue
                let attributedString = NSAttributedString(string: string, attributes: attrs)
                
                attributedString.draw(with: CGRect(x: CGFloat(text["x"].int!), y: CGFloat(text["y"].int!), width: attributedString.size().width, height: attributedString.size().height), options: .usesLineFragmentOrigin, context: nil)
            }
        }
        
        return img
    }
    
    
    @State private var offset: CGFloat = 0
    //@State private var index = 0
    @State private var showingDetail = false
    @State private var selectedTimetableJsonWeekLoad: TimetableJsonWeekLoad? = nil
    
    @State private var selection = 0
    @State private var oldSelection = 0
    @State private var hasLoadedFirstTime = false
    @State private var lastUsedProfile: Profile? = nil
    
    private var standardWeekNumLimit = 4
    
    @GestureState var scale: CGFloat = 1.0
    
    @State private var isShareSheetShowing = false
    
    let spacing: CGFloat = 20
    
    func getSelectedWeek () -> Int {
        return self.foldWeek(week: self.weekController.getCurrentWeek() + self.selection)
    }
    
    var body: some View {
        
        ZStack {
            
            
            VStack {
                /*HStack {
                 Text("Vecka \(self.foldWeek(week: self.weekController.getCurrentWeek() + selection))").font(.title).bold()
                 }
                 */
                Spacer()
                if (self.weekController.getTimetableJsonWeekLoad(ofWeek: self.getSelectedWeek()) != nil) {
                    VStack {
                        HStack {
                            Text("Vecka \(self.foldWeek(week: self.weekController.getCurrentWeek() + selection))").bold()
                            Spacer()
                        }
                        Image(uiImage: self.drawTimetable(timetableJson: self.weekController.getTimetableJsonWeekLoad(ofWeek: self.getSelectedWeek())!.timetableJson)).resizable().aspectRatio(contentMode: .fit).pinchToZoom()
                    }.padding(25).background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(20)
                }
                else {
                    Text("Laddar...")
                }
                
                Spacer()
                HStack {
                    Button(action: {
                        self.selection -= 1
                    }) {
                        // Text("Förra")
                        Image(systemName: "arrow.left").font(Font.body.weight(.bold))
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
                            self.weekController.targetSize = CGSize(width: 600 * 1.5, height: 600 * 1.5 * 1.41428571429)
                            self.weekController.load(profile: profile, ofWeek: self.foldWeek(week: self.weekController.getCurrentWeek() + value))
                            self.oldSelection = value
                            self.hasLoadedFirstTime = true
                        }
                    }
                    
                    Spacer()
                    Button(action: {
                        self.selection += 1
                    }) {
                        Image(systemName: "arrow.right").font(Font.body.weight(.bold))
                    }.padding()
                }
                
                
                
            }.padding(10).onAppear {
                if (self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")}) != self.lastUsedProfile) {
                    self.weekController.timetableJsonWeekLoads = []
                    self.hasLoadedFirstTime = false
                    self.lastUsedProfile = self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")})
                }
            }
        }.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct HorizontalDatePicker : View {
    let dateNumberLimit: Int
    @State var selection: Int = 0
    @EnvironmentObject var todayController: TodayController
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    
    
    func addDaysToCalendar(num: Int) -> Date {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = num
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        return futureDate!
    }
    
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
    
    func getSelectedBackgroundColor(index: Int, selected: Int) -> Color {
        if (index == selected) {
            return Color(UIColor.systemBlue)
        }
        else if (index == 0) {
            return Color(UIColor.systemGray5)
        }
        else {
            return Color(UIColor.white).opacity(0)
        }
    }
    
    func getTodayForegroundColor(index: Int) -> Color {
        if (index == 0) {
            return Color(UIColor.systemBlue)
            // return Color(UIColor.systemRed)
        }
        else {
            return Color(UIColor.black).opacity(0)
            // return Color(UIColor.label)
        }
    }
    
    func getSelectedForegroundColor(index: Int, selected: Int) -> Color {
        if (index == selected) {
            return Color(UIColor.white)
        }
        else {
            return Color(UIColor.label)
        }
    }
    
    var body: some View {
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Spacer()
                ForEach(0..<dateNumberLimit) { index in
                    Button(action: {
                        self.selection = index
                        self.todayController.selectedDate = self.addDaysToCalendar(num: index)
                        self.todayController.load(profile: self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")}))
                    }) {
                        VStack {
                            Text(self.getDayNameOfDate(date: self.addDaysToCalendar(num: index))).foregroundColor(Color(UIColor.secondaryLabel)).font(.caption).padding(EdgeInsets(top: 0, leading: 0, bottom: 7, trailing: 0))
                            Text(self.getDayOfDate(date: self.addDaysToCalendar(num: index))).fontWeight(self.selection == index ? .bold : .regular).padding(10).background(self.getSelectedBackgroundColor(index: index, selected: self.selection)).clipShape(Circle()).foregroundColor(self.getSelectedForegroundColor(index: index, selected: self.selection))
                        }.frame(width: 55).padding(5)//.background(self.getSelectedBackgroundColor(index: index, selected: self.selection)).cornerRadius(15)
                    }
                }
                Spacer()
            }.onAppear {
                self.selection = 0
                self.todayController.selectedDate = self.todayController.currentDate
                self.todayController.load(profile: self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")}))
            }
        }
    }
}

struct TodayView: View {
    @Binding var eventList: [Event]
    // @State var selectedDate: Date = Date()
    @EnvironmentObject var todayController: TodayController
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HorizontalDatePicker(dateNumberLimit: 14).padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                VStack(alignment: .leading) {
                    Text("\(todayController.assistantMessage())")
                        .font(.system(size: 20)).bold()
                }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                if (eventList.count > 0) {
                    ScrollView(.vertical) {
                        SchemaCardStack(eventList: self.$eventList)
                    }
                }
                else {
                    if (eventList.count == 0) {
                        Spacer()
                        VStack {
                            HStack {
                                Spacer()
                                if (self.todayController.fetchError == nil) {
                                    Text("Ingenting för idag, se fliken Veckan för en översikt.")
                                }
                                else {
                                    Text(self.todayController.fetchError!.message).foregroundColor(Color(UIColor.red))
                                }
                                Spacer()
                            }.padding(30)
                        }
                    }
                    Spacer()
                }
            }
        }.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct SchemaCardStack: View {
    @Binding var eventList: [Event]
    var body: some View {
        VStack {
            ForEach(eventList.indices, id: \.self) { index in
                
                Group {
                    SchemaCard(event: self.eventList[index])
                    if (self.eventList.indices.contains(index + 1)) {
                        if (self.shouldUseRecess(end: self.eventList[index].end, start: self.eventList[index + 1].start)) {
                            Recess(previous: self.eventList[index], next: self.eventList[index + 1])
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
            Text("rast i \(TodayController.getMinutesFromDates(from: previous.end, to: next.start)) minuter").font(.footnote)
        }.foregroundColor(self.todayDelegate.isActive(from: previous.end, to: next.start) ? Color(UIColor.systemBlue) : Color(UIColor.secondaryLabel)).padding(.bottom, 2)
    }
}


struct SchemaView_Previews: PreviewProvider {
    static var previews: some View {
        SchemaView()
    }
}
