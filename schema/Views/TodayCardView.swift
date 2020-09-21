//
//  TodayCardView.swift
//  schema
//
//  Created by Victor Forsgren on 2020-09-18.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import SwiftUI


//MARK: Schema card stack
struct SchemaCardStack: View {
    @EnvironmentObject var todayController: TodayController
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    
    // FIXME: Gå efter något annat än bara selectedDate?
    func getEventList() -> [Event] {
        guard let eventList = todayController.getTimetableObjectLoadFromDate(date: self.todayController.selectedDate) else {
            return []
        }
        return eventList.eventList
    }
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
        if (DateExtensions.getMinutesFromDates(from: end, to: start) > 0) {
            return true
        }
        return false
    }
}

//MARK: Schema card
struct SchemaCard: View {
    let event: Event
    @ObservedObject var settings = UserSettings()
    @EnvironmentObject var todayDelegate: TodayController
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 5) {
                if (self.todayDelegate.isActive(from: event.start, to: event.end)) {
                    HStack {
                        Text("Just nu").bold()
                        //FIXME
                        ProgressView(value: self.todayDelegate.completionRate(start: event.start, end: event.end, current: self.todayDelegate.currentDate))
                    }.font(.footnote).foregroundColor(Color(UIColor.systemBlue))
                }
                HStack {
                    //Circle().strokeBorder(Color(event.color.darker(by: 30)!), lineWidth: 2).background(Circle().foregroundColor(Color(event.color))).frame(width: 12, height: 12)
                    if (settings.showColorCircleInTodayView) {
                        ColorCircle(uiColor: event.color).frame(width: 12, height: 12)
                    }
                    Text(event.title).font(.headline)
                    Spacer()
                }
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

//MARK: Recess
struct Recess: View {
    let previous: Event
    let next: Event
    
    @EnvironmentObject var todayDelegate: TodayController
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.down")
            Text("rast i \(TodayController.minutesToHourMinuteString(minutes: DateExtensions.getMinutesFromDates(from: previous.end, to: next.start)))").font(.footnote)
        }.foregroundColor(self.todayDelegate.isActive(from: previous.end, to: next.start) ? Color(UIColor.systemBlue) : Color(UIColor.secondaryLabel)).padding(.bottom, 2)
    }
}

struct ColorCircle: View {
    let uiColor: UIColor
    @Environment(\.colorScheme) var colorScheme

    
    func strokeBorderColor() -> UIColor {
        if (colorScheme == .light) {
            return uiColor.darker(by: 30)!
        }
        else {
            return uiColor.lighter(by: 30)!
        }
    }
    
    var body: some View {
        Circle().strokeBorder(Color(strokeBorderColor()), lineWidth: 2).background(Circle().foregroundColor(Color(uiColor)))
    }
}
