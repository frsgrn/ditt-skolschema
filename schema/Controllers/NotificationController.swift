//
//  NotificationController.swift
//  schema
//
//  Created by Victor Forsgren on 2020-09-25.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import RealmSwift

class NotificationController {
    public static func createNotification(event: Event) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: event.start)
        
        print(components)
        
        let content = UNMutableNotificationContent()
        content.title = event.title + " börjar snart"
        content.body = "Lektionen börjar " + Event.getHourMinuteString(date: event.start)
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: <#T##TimeInterval#>, repeats: <#T##Bool#>, repeats: false)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let uuidString = UUID().uuidString
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request) { (error) in
            if (error == nil) {
                print("Notification scheduled")
                let realm = try! Realm(configuration: PersistentRealmStack.getRealmConfig())
                let notification = p_Notification(notificationIdentifier: uuidString, eventIdentifier: event.id)
                try! realm.write {
                    realm.add(notification)
                }
            } else {
                print(error)
            }
        }
    }
    
    public static func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
