//
//  Notification.swift
//  schema
//
//  Created by Victor Forsgren on 2020-09-25.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import Foundation
import RealmSwift

public class p_Notification: Object {
    @objc dynamic var notificationIdentifier: String = ""
    @objc dynamic var eventIdentifier: String = ""
    
    convenience init(notificationIdentifier: String, eventIdentifier: String) {
        self.init()
        self.notificationIdentifier = notificationIdentifier
        self.eventIdentifier = eventIdentifier
    }
}
