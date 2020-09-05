//
//  ProfileController.swift
//  schema
//
//  Created by Victor Forsgren on 2020-08-29.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import Firebase

class ProfileController {
    static func setProfile(profile: Profile) {
        UserDefaults.standard.set(profile.id?.uuidString, forKey: "selectedProfileId")
        Analytics.setUserProperty(profile.title, forName: "selected_profile")
        Analytics.setUserProperty(profile.subTitle, forName: "selected_school")
    }
}
