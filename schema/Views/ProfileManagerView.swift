//
//  ProfileManagerView.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-20.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import SwiftUI

struct ProfileManagerView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var todayController: TodayController
    @EnvironmentObject var weekController: WeekController

    @State var showingDetail = false
    @State private var selectedProfileId = UserDefaults.standard.string(forKey: "selectedProfileId") ?? ""
    
    var body: some View {
        NavigationView {
        List {
                //ForEach(profiles, id: \.id) { profile in
                ProfileList()
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
                }.navigationViewStyle(StackNavigationViewStyle()).font(.body)
            })
            .listStyle(InsetGroupedListStyle())
    }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProfileList: View {
    @EnvironmentObject var todayController: TodayController
    @EnvironmentObject var weekController: WeekController
    func deleteProfiles(at offsets: IndexSet) {
        if (ProfileManager.getProfiles().count <= 1) {
            return
        }
        /*
        for offset in offsets {
            let profile =  profiles[offset]
            if (profile == self.profiles.first(where: {$0.id!.uuidString == self.selectedProfileId})) {
                if (profiles.count != 1) {
                    selectFirstProfile()
                }
            }
            moc.delete(profile)
        }
        try? moc.save()*/
        /*var profiles = ProfileManager.getProfiles()
        for offset in offsets {
            let profile = profiles[offset]
            profiles.remove(at: offset)
            if (ProfileManager.getSelectedProfile().id == profile.id) {
                selectFirstProfile()
            }
        }
        ProfileManager.saveProfiles(profiles: profiles)*/
        for offset in offsets {
            let profileId = ProfileManager.getProfiles()[offset].id
            
            ProfileManager.removeProfile(index: offset)
            if profileId == ProfileManager.getSelectedProfileId() {
                selectFirstProfile()
            }
        }
    }
    
    func selectFirstProfile() {
        /*if (self.profiles.first(where: {$0.id!.uuidString == self.selectedProfileId}) == nil && self.profiles.count > 0) {
            //self.selectProfile(profile: self.profiles[0])
        }*/
        if (ProfileManager.getProfiles().count > 0) {
            self.selectProfile(profile: ProfileManager.getProfiles()[0])
        }
    }
    
    /*func selectProfile(profile: Profile) {
        let id:UUID = profile.id!
        self.selectedProfileId = id.uuidString
        ProfileController.setProfile(profile: profile)
        
        self.weekController.timetableJsonWeekLoads = []
        self.todayController.timetableObjectLoads = []
        
        self.todayController.load(profile: profile)
        self.weekController.load(profile: profile)
    }*/
    
    func selectProfile(profile: p_Profile) {
        // ProfileController.setProfile(profile: profile)
        
        self.weekController.timetableJsonWeekLoads = []
        self.todayController.timetableObjectLoads = []
        
        ProfileManager.selectProfile(profile)
        
        self.todayController.load(profile)
        self.weekController.load(profile)
    }
    var body: some View {
        ForEach(ProfileManager.getProfiles(), id: \.id) { profile in
            Button(action: {
                self.selectProfile(profile: profile)
            }) {
                HStack {
                    VStack (alignment: .leading){
                        Text(profile.title).bold()
                        Text(profile.subTitle).foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    Spacer()
                    if (ProfileManager.getSelectedProfile() != nil) {
                        if (ProfileManager.getSelectedProfile()!.id == profile.id) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(Color(UIColor.systemBlue))
                        }
                    }
                }
            }.foregroundColor(Color(UIColor.label))
        }.onDelete(perform: deleteProfiles)
    }
}

struct ProfileManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileManagerView()
    }
}
