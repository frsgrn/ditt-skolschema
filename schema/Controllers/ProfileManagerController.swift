//
//  ProfileManagerController.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-12.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

class ProfileManagerController: ObservableObject {
    /*@Published var eventList: [Event] = []
    @Published var loaded: Bool = false
    @Published var specifiedDate: Date = Date()
    */
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @Environment(\.managedObjectContext) var moc
    
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
        UserDefaults.standard.set(self.selectedProfileId, forKey: "selectedProfileId")
        self.todayDelegate.load(profile: profile)
    }
}
