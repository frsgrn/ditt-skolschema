//
//  PersistentRealmStack.swift
//  schema
//
//  Created by Victor Forsgren on 2020-09-26.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import RealmSwift

class PersistentRealmStack {
    public static func getRealmConfig() -> Realm.Configuration {
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.dittskolschema")!
            .appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: fileURL, schemaVersion: 2, objectTypes: [p_Profile.self, p_Notification.self])
        return config
    }
}
