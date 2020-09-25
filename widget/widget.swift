//
//  widget.swift
//  widget
//
//  Created by Victor Forsgren on 2020-09-22.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),currentDate: Date(), timetableObjectLoad: nil, isPreview: true/*, configuration: ConfigurationIntent()*/)
    }
    
    func getSnapshot(/*for configuration: ConfigurationIntent, */in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(),currentDate: Date(), timetableObjectLoad: nil, isPreview: true/*, configuration: configuration*/)
        completion(entry)
    }
    
    func getTimeline(/*for configuration: ConfigurationIntent, */in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        
        
        let todayController = TodayController()
        todayController.currentDate = Date()
        todayController.selectedDate = todayController.currentDate
        
        
        todayController.load(ProfileManager.getSelectedProfile(), completion: { (timetableObjectLoad) in
            print("completion")
            print(timetableObjectLoad)
            for event in timetableObjectLoad.eventList {
                let entry1 = SimpleEntry(date: event.start, currentDate: event.start,timetableObjectLoad: timetableObjectLoad, isPreview: false/*, configuration: configuration*/)
                let entry2 = SimpleEntry(date: event.end, currentDate: event.end,timetableObjectLoad: timetableObjectLoad, isPreview: false/*, configuration: configuration*/)
                
                entries.append(entry1)
                entries.append(entry2)
            }
            
            if (timetableObjectLoad.eventList.count == 0) {
                entries.append(SimpleEntry(date: Date(), currentDate: Date(), timetableObjectLoad: timetableObjectLoad, isPreview: false))
            }
            
            let now = Calendar.current.dateComponents(in: .current, from: Date().startOfDay)
            
            let tomorrow = DateComponents(year: now.year, month: now.month, day: now.day! + 1, hour: now.hour! + 3)
            let dateTomorrow = Calendar.current.date(from: tomorrow)!
            print(dateTomorrow)
            
            let timeline = Timeline(entries: entries, policy: .after(dateTomorrow))
            completion(timeline)
        })
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let currentDate: Date
    let timetableObjectLoad: TimetableObjectLoad?
    let isPreview: Bool
    //let configuration: ConfigurationIntent
}

struct widgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    @State var eventCap = 2
    
    func filterEventList() -> [Event] {
        var eventList: [Event] = []
        for event in entry.timetableObjectLoad!.eventList {
            if (entry.currentDate < event.end) {
                eventList.append(event)
            }
        }
        return eventList
    }
    
    func numNotShown() -> Int {
        return filterEventList().count - eventCap
    }
    
    var body: some View {
        if(entry.isPreview) {
            VStack {
                Spacer()
                HStack {
                    Text("Blablbbalal").font(.footnote).foregroundColor(Color(UIColor.secondaryLabel)).bold()
                    Spacer()
                }
                HStack {
                    Text("hejsan")
                    Image(systemName: "minus")
                    Text("hoppsan")
                    Spacer()
                }.foregroundColor(Color(UIColor.secondaryLabel)).font(.caption)
                
                HStack {
                    Text("hejsan")
                    Image(systemName: "minus")
                    Text("hoppsan")
                    Spacer()
                }.foregroundColor(Color(UIColor.secondaryLabel)).font(.caption)
                HStack {
                    Text("hejsan")
                    Image(systemName: "minus")
                    Text("hoppsan")
                    Spacer()
                }.foregroundColor(Color(UIColor.secondaryLabel)).font(.caption)
                
                Spacer()
            }.padding().redacted(reason: .placeholder)
        }
        else if (entry.timetableObjectLoad != nil) {
            VStack {
                if (ProfileManager.getSelectedProfile() != nil) {
                    HStack {
                        Text(ProfileManager.getSelectedProfile()!.title).bold()
                        Spacer()
                        if (family == .systemMedium) {
                            Text(entry.date.dayDate())
                        }
                    }.font(.footnote).foregroundColor(Color(UIColor.secondaryLabel))
                }
                ForEach(filterEventList().indices.prefix(eventCap), id: \.self) { index in
                    //HStack {
                    HStack {
                        //Rectangle().frame(width: 5).background(Color(filterEventList()[index].uiColor))
                        ColorBar(uiColor: filterEventList()[index].color)
                        VStack {
                            HStack {
                                Text(filterEventList()[index].title).truncationMode(.tail)
                                Spacer()
                            }.font(.footnote)
                            
                            HStack {
                                Timespan(from: filterEventList()[index].start, to: filterEventList()[index].end)
                                /*Text(Event.getHourMinuteString(date: filterEventList()[index].start))
                                Image(systemName: "minus")
                                Text(Event.getHourMinuteString(date: filterEventList()[index].end))*/
                                Spacer()
                            }.foregroundColor(Color(UIColor.secondaryLabel)).font(.caption)
                        }
                    }.frame(height: 35)
                    //}
                }
                if (filterEventList().count <= eventCap) {
                    HStack(spacing: 5) {
                        if (entry.timetableObjectLoad!.eventList.count > 0) {
                            Text("\(Event.getHourMinuteString(date: entry.timetableObjectLoad!.eventList[entry.timetableObjectLoad!.eventList.count-1].end))").foregroundColor(Color(UIColor.secondaryLabel))
                            Text("slut för idag")
                            //if (entry.timetableObjectLoad!.eventList.count > 0) {
                                
                                //Image(systemName: "minus")
                            //}
                            //Text("slut")//.foregroundColor(Color(UIColor.secondaryLabel))
                            
                        }
                        else {
                            Text("Ingenting för idag")
                        }
                        Spacer()
                    }.font(.caption)
                }
                // Text("\(entry.timetableObjectLoad!.eventList.count)")
                if (numNotShown() > 0) {
                    HStack {
                        Text("+ \(numNotShown())").font(.footnote).foregroundColor(Color(UIColor.secondaryLabel))
                        Spacer()
                    }
                }
                Spacer()
            }.padding()
        }
        else {
            Text("Kunde inte hämta schema").bold().padding()
        }
        
    }
}

@main
struct widget: Widget {
    let kind: String = "widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Översikt")
        .description("Se en kort översikt av kommande lektioner.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        widgetEntryView(entry: SimpleEntry(date: Date(),currentDate: Date(), timetableObjectLoad: nil, isPreview: true/*, configuration: ConfigurationIntent()*/))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
