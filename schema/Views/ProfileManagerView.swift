//
//  ProfileManagerView.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-20.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import SwiftUI

struct ProfileManagerView: View {
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var todayController: TodayController
    @EnvironmentObject var weekController: WeekController

    @State var showingDetail = false
    @State private var selectedProfileId = UserDefaults.standard.string(forKey: "selectedProfileId") ?? ""
    
    func deleteProfiles(at offsets: IndexSet) {
        for offset in offsets {
            let profile =  profiles[offset]
            moc.delete(profile)
        }
        try? moc.save()
        selectFirstProfile()
    }
    
    func selectFirstProfile() {
        if (self.profiles.first(where: {$0.id!.uuidString == self.selectedProfileId}) == nil && self.profiles.count > 0) {
            self.selectProfile(profile: self.profiles[0])
        }
    }
    
    func selectProfile(profile: Profile) {
        let id:UUID = profile.id!
        self.selectedProfileId = id.uuidString
        ProfileController.setProfile(profile: profile)
        self.todayController.load(profile: profile)
        self.weekController.timetableJsonWeekLoads = []
        self.todayController.timetableObjectLoads = []
    }
    
    var body: some View {
        NavigationView {
        List {
                ForEach(profiles, id: \.id) { profile in
                    Button(action: {
                        self.selectProfile(profile: profile)
                    }) {
                        HStack {
                            VStack (alignment: .leading){
                                Text(profile.title ?? "okänd").bold()
                                Text(profile.subTitle ?? "okänd")
                            }
                            Spacer()
                            if (self.profiles.first(where: {$0.id!.uuidString == self.selectedProfileId}) == profile) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(Color(UIColor.systemBlue))
                            }
                        }
                    }.foregroundColor(Color(UIColor.label))
                }.onDelete(perform: deleteProfiles).onAppear {
                    self.selectFirstProfile()
                }
        }.navigationBarTitle("Hantera scheman", displayMode: .automatic)
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                self.showingDetail.toggle()
            }) {
                HStack {
                    Text("Lägg till")
                    Image(systemName: "plus.circle.fill")
                }
            }.sheet(isPresented: $showingDetail) {
                NavigationView {
                    ChooseDomain(showingDetail: self.$showingDetail).environment(\.managedObjectContext, self.moc)
                }.navigationViewStyle(StackNavigationViewStyle())
            })
            .listStyle(GroupedListStyle())
    }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProfileManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileManagerView()
    }
}
