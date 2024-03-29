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

// MARK: Week view
struct WeekView: View {
    @EnvironmentObject var weekController: WeekController
    @EnvironmentObject var todayController: TodayController
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var settings = UserSettings()
    
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
        //return self.foldWeek(week: self.weekController.getCurrentWeek() + self.selection)
        return self.weekController.selectedWeek
    }
    
    var colors: [Color] = [.blue, .green, .red, .orange]
    
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
                                    ProgressView()
                                    // Spinner(isAnimating: true, style: .medium, color: .gray)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                    HorizontalWeekPicker(selection: self.$selection)
                }
            }.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)).navigationBarTitle("Vecka \(self.getSelectedWeek())", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.weekController.timetableJsonWeekLoads = []
                        //self.weekController.load(profile: self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")}))
                        self.weekController.load(ProfileManager.getSelectedProfile())
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                    }
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
        
    }
}

// MARK: Horizontal week picker
struct HorizontalWeekPicker: View {
    @Binding var selection: Int
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
                return Color(UIColor.systemBlue)
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
            return Color(UIColor.systemBlue)
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
                ForEach(0...51, id: \.self) { index in
                    Button(action: {
                        self.selection = index
                        //let profile = self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")})
                        self.weekController.selectedWeek = self.getSelectedWeek()
                        //self.weekController.load(profile: profile)
                        self.weekController.load(ProfileManager.getSelectedProfile())
                    }) {
                        HStack {
                            Text("vecka").padding([.leading], 10).foregroundColor(Color(UIColor.label))
                            Text("\(self.foldWeek(week: self.weekController.getCurrentWeek() + index))")
                                .if(self.isBold(index: index)) { view in
                                    view.bold()
                                }
                                .frame(width: 35, height: 35)
                                .background(self.getCircleBackgroundColor(index: index))
                                .foregroundColor(self.getForegroundColor(index: index))
                                .clipShape(Circle())
                        }.padding(5).background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(30)
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))/*.onAppear {
             let profile = self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")})
             self.weekController.load(profile: profile, ofWeek: self.getSelectedWeek())
             }*/
        }
    }
}

// MARK: Today view
struct TodayView: View {
    //@Binding var eventList: [Event]
    @EnvironmentObject var todayController: TodayController
    @State private var birthDate = Date()
    
    @State private var dragAmount = CGSize.zero
    
    
    var body: some View {
        NavigationView {
            ZStack {
            //VStack(spacing: 0) {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack {
                        VStack {
                            HStack {
                                Text("\(todayController.assistantMessage())").font(.system(size: 20)).bold()
                                Spacer()
                            }
                            if (!Calendar.current.isDate(todayController.selectedDate, inSameDayAs:todayController.currentDate)) {
                                HStack {
                                    Button(action: {
                                        todayController.selectedDate = todayController.currentDate
                                        todayController.load(ProfileManager.getSelectedProfile())
                                    }) {
                                        Text("Det här är inte idag, gå tillbaka?").font(.footnote)
                                    }
                                    Spacer()
                                }.padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
                            }
                        }.padding().padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))

                        if (self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate) != nil) {
                            if (self.todayController.getSelectedEventList().count > 0) {
                                SchemaCardStack()
                            }
                            else if (self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate)!.fetchError != nil) {
                                Text(self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate)!.fetchError!.message).foregroundColor(Color(UIColor.red)).padding()
                                Spacer()
                            }
                            else {
                                HStack {
                                    Image("yoda").resizable().aspectRatio(contentMode: .fit).frame(width: 250).cornerRadius(20).padding()
                                    Spacer()
                                }
                            }
                        }
                        
                    }.animation(.none)
                }
                .offset(x: self.dragAmount.width)
                //.animation(Animation.spring())
                // .transition(AnyTransition.slide)
                .simultaneousGesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onChanged {
                                self.dragAmount = $0.translation
                                
                            }
                            .onEnded({ value in
                                withAnimation(.spring()) {
                                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                                        
                                self.dragAmount = .zero
                                if value.translation.width < -100 {
                                    // left
                                    print("left")
                                    var dateComponent = DateComponents()
                                    dateComponent.day = 1
                                    let futureDate = Calendar.current.date(byAdding: dateComponent, to: self.todayController.selectedDate)
                                    self.todayController.selectedDate = futureDate!
                                    self.todayController.load(ProfileManager.getSelectedProfile())
                                    impactMed.impactOccurred()
                                }

                                if value.translation.width > 100 {
                                    // right
                                    print("right")
                                    //self.todayController.$currentDate = Date.
                                    var dateComponent = DateComponents()
                                    dateComponent.day = -1
                                    let futureDate = Calendar.current.date(byAdding: dateComponent, to: self.todayController.selectedDate)
                                    self.todayController.selectedDate = futureDate!
                                    self.todayController.load(ProfileManager.getSelectedProfile())
                                    impactMed.impactOccurred()
                                }
                                if value.translation.height < 0 {
                                    // up
                                }

                                if value.translation.height > 0 {
                                    // down
                                }
                                }
                            }))//.animation(Animation.spring(), value: dragAmount)
                
                .navigationBarTitle(Text("Skoldagen"/*self.todayController.selectedDate.dayDate().capitalizingFirstLetter()*/), displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        /*Button(action: {
                            self.todayController.timetableObjectLoads = []
                            //self.todayController.load(profile: self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")}))
                            self.todayController.load(ProfileManager.getSelectedProfile())
                        }) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                        }*/
                        HorizontalDatePicker(dateNumberLimit: 1)
                    }
                }
                //.background(Color("DatePickerBackground"))
                /*VStack*/ /*ScrollView {
                    if (self.todayController.getTimetableObjectLoadFromDate(date: todayController.selectedDate) != nil) {
                        if (self.todayController.getSelectedEventList().count > 0) {
                            ScrollView {
                                VStack {
                                    HStack {
                                        Text("\(todayController.assistantMessage())").font(.system(size: 20)).bold()
                                        Spacer()
                                    }
                                }
                                //VStack {
                                    //HorizontalDatePicker(dateNumberLimit: 14).padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                                    /*VStack {
                                        HStack {
                                            VStack {
                                        Text("\(todayController.assistantMessage())").font(.system(size: 20)).bold()
                                                if (!Calendar.current.isDate(todayController.selectedDate, inSameDayAs:todayController.currentDate)) {
                                                    HStack {
                                                        Button(action: {
                                                            todayController.selectedDate = todayController.currentDate
                                                            todayController.load(ProfileManager.getSelectedProfile())
                                                        }) {
                                                            Text("Du tittar just nu in i framtiden, gå tillbaka till idag?").font(.footnote)
                                                        }
                                                        Spacer()
                                                    }.padding(EdgeInsets(top: 3, leading: 6, bottom: 0, trailing: 0))
                                                }
                                            }
                                            Spacer()
                                        }.padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                                        
                                    }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                                }.padding(EdgeInsets(top: 13, leading: 0, bottom: 10, trailing: 0))*/
                                SchemaCardStack().padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
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
                            //Spinner(isAnimating: true, style: .medium, color: .gray).padding()
                            ProgressView()
                            Spacer()
                        }
                        Spacer()
                    }
                }*/
                
            //}
            //.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            }
        }//.background(Color(UIColor.systemGroupedBackground))//.navigationViewStyle(StackNavigationStyle())
    }
}

//MARK: Horizontal date picker
struct HorizontalDatePicker : View {
    
    @EnvironmentObject var todayController: TodayController
    @State var dateNumberLimit: Int
    
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
                return Color(UIColor.systemGray3)
            }
            else {
                return Color(UIColor.systemBlue)
            }
        }
        else {
            return Color(UIColor.white).opacity(0)
        }
    }
    
    func getDateForegroundColor(index: Int) -> Color {
        if (self.isOnSameDay(date: self.todayController.selectedDate, date2: self.addDaysToCurrentDate(num: index))) {
            return Color(UIColor.label)
        }
        else if (index == 0) {
            return Color(UIColor.systemBlue)
        }
        else {
            return Color(UIColor.label)
        }
    }
    
    func getDayForegroundColor(index: Int) -> Color {
        if (self.isOnSameDay(date: self.todayController.selectedDate, date2: self.addDaysToCurrentDate(num: index))) {
            return Color(UIColor.label)
        }
        else if (index == 0) {
            return Color(UIColor.systemBlue)
        }
        else {
            return Color(UIColor.label)
        }
    }
    
    func isBold(index: Int) -> Bool {
        return self.isOnSameDay(date: self.todayController.selectedDate, date2: self.addDaysToCurrentDate(num: index))
    }
    
    func getBinding () -> Binding<Date> {
            return Binding(
                get: { [self] in
                    (self.todayController.selectedDate)
                },
                set: { [self] in
                    self.todayController.selectedDate = $0
                    self.todayController.load(ProfileManager.getSelectedProfile())
                }
            )
    }
    
    
    var body: some View {
        
        return //ScrollView(.horizontal, showsIndicators: false) {
            DatePicker(
                    "",
                selection: getBinding(),
                displayedComponents: [.date]
                )
            /*HStack {
                ForEach(0..<dateNumberLimit) { index in
                    Button(action: {
                        self.todayController.selectedDate = self.addDaysToCurrentDate(num: index)
                        self.todayController.load(ProfileManager.getSelectedProfile())
                    }) {
                        /*VStack {
                            Text(self.getDayNameOfDate(date: self.addDaysToCurrentDate(num: index)))
                                .font(.caption)
                                .frame(width: 40)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Text(self.getDayOfDate(date: self.addDaysToCurrentDate(num: index)))
                                .fontWeight(self.isBold(index: index) ? .bold : .regular)
                                .frame(width: 40, height: 40)
                                .background(self.getCircleBackgroundColor(index: index))
                                .foregroundColor(self.getDateForegroundColor(index: index))
                                .clipShape(Circle())
                        }.padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))*/
                        HStack {
                            Text(self.getDayNameOfDate(date: self.addDaysToCurrentDate(num: index))).foregroundColor(self.getDayForegroundColor(index: index))
                                Text(self.getDayOfDate(date: self.addDaysToCurrentDate(num: index))).foregroundColor(self.getDateForegroundColor(index: index))
                            
                        }.padding(7).background(self.getCircleBackgroundColor(index: index)).cornerRadius(5)
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))*/
        //}
    }
}

struct SchemaView_Previews: PreviewProvider {
    static var previews: some View {
        SchemaView()
    }
}
