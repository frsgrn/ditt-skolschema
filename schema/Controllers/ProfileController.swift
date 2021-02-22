//
//  ProfileController.swift
//  schema
//
//  Created by Victor Forsgren on 2020-09-19.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
//import CoreData
import SwiftUI
//import UIKit
import WidgetKit
import RealmSwift

/*@objc(Profile_)
class Profile_ : NSObject, NSCoding {
    var classGUID: String?
    var teacherGUID: String?
    var signature: String?
    
    var domain: String
    var id: String
    var schoolGUID: String
    var title: String
    var subTitle: String
    
    init(classGUID: String?, schoolGUID: String, teacherGUID: String?, domain: String, id: String, signature: String?, title: String, subTitle: String) {
        self.classGUID = classGUID
        self.schoolGUID = schoolGUID
        self.teacherGUID = teacherGUID
        self.signature = signature
        self.domain = domain
        self.id = id
        self.title = title
        self.subTitle = subTitle
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let classGUID = aDecoder.decodeObject(forKey: "classGUID") as! String?
        let schoolGUID = aDecoder.decodeObject(forKey: "schoolGUID") as! String
        let teacherGUID = aDecoder.decodeObject(forKey: "teacherGUID") as! String?
        let signature = aDecoder.decodeObject(forKey: "signature") as! String?
        let domain = aDecoder.decodeObject(forKey: "domain") as! String
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let title = aDecoder.decodeObject(forKey: "title") as! String
        let subTitle = aDecoder.decodeObject(forKey: "subTitle") as! String
        
        self.init(classGUID: classGUID, schoolGUID: schoolGUID, teacherGUID: teacherGUID, domain: domain, id: id, signature: signature, title: title, subTitle: subTitle)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(classGUID, forKey: "classGUID")
        aCoder.encode(schoolGUID, forKey: "schoolGUID")
        aCoder.encode(teacherGUID, forKey: "teacherGUID")
        aCoder.encode(signature, forKey: "signature")
        aCoder.encode(domain, forKey: "domain")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(subTitle, forKey: "subTitle")
    }
}*/

class ProfileManager {
    /*
    public static func saveProfiles(profiles: [Profile_]) {
        let userDefaults = getUserDefaults()
        
        NSKeyedUnarchiver.setClass(Profile_.self, forClassName: "Profile_")
        NSKeyedArchiver.setClassName("Profile_", for: Profile_.self)
        
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: profiles)
        userDefaults.set(encodedData, forKey: "profiles")
        userDefaults.synchronize()
    }
    
    public static func getProfiles() -> [Profile_] {
        let decoded  = getUserDefaults().data(forKey: "profiles")
        if (decoded == nil) {
            return []
        }
        NSKeyedUnarchiver.setClass(Profile_.self, forClassName: "Profile_")
        NSKeyedArchiver.setClassName("Profile_", for: Profile_.self)
        
        //NSKeyedUnarchiver.unarchivedObject(ofClass: Profile_.self, from: decoded!)
        
        let decodedProfiles = try! NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [Profile_]
        //let decodedProfiles = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded!) as! [Profile_]
        return decodedProfiles
        
        
        
        //let profiles = Profile.fetchRequest()
    }
    
    public static func addProfile(profile: Profile_) {
        var profiles = getProfiles()
        profiles.append(profile)
        saveProfiles(profiles: profiles)
        // selectProfile(profile: profile)
    }
    public static func getUserDefaults() -> UserDefaults {
        return UserDefaults(suiteName: "group.dittskolschema") ?? UserDefaults.standard
    }
    public static func deleteProfile(id: String) {
        var profiles = getProfiles()
        profiles = profiles.filter {$0.id != id}
        saveProfiles(profiles: profiles)
    }
    
    public static func deleteProfile(index: Int) {
        var profiles = getProfiles()
        profiles.remove(at: index)
        saveProfiles(profiles: profiles)
    }
    
    public static func selectProfile(profile: Profile_) {
        print("selecting " + profile.id)
        getUserDefaults().set(profile.id, forKey: "selectedProfileId")
    }
    
    public static func getSelectedProfile() -> Profile_ {
        let profiles = getProfiles()
        for profile in profiles {
            if profile.id == getUserDefaults().string(forKey: "selectedProfileId") {
                return profile
            }
        }
        return profiles[0]
    }*/
    public static func addProfile(profile: p_Profile) {
        let realm = try! Realm(configuration: PersistentRealmStack.getRealmConfig())
        try! realm.write {
            realm.add(profile)
        }
    }
    
    public static func removeProfile(index: Int) {
        let realm = try! Realm(configuration: PersistentRealmStack.getRealmConfig())
        let profiles = getProfiles()
        try? realm.write {
            realm.delete(profiles[index])
        }
    }
    
    public static func getSelectedProfile() -> p_Profile? {
        let profiles = getProfiles()
        let targetID = UserDefaults(suiteName: "group.dittskolschema")?.string(forKey: "selectedProfileId") ?? ""
        for profile in profiles {
            if profile.id == targetID {
                return profile
            }
        }
        return nil
    }
    
    public static func getProfiles() -> Results<p_Profile> {
        let realm = try! Realm(configuration: PersistentRealmStack.getRealmConfig())
        let profiles = realm.objects(p_Profile.self)
        return profiles
    }
    
    public static func getSelectedProfileId() -> String {
        return UserDefaults(suiteName: "group.dittskolschema")?.string(forKey: "selectedProfileId") ?? ""
    }
    
    public static func selectProfile(_ profile: p_Profile) {
        UserDefaults(suiteName: "group.dittskolschema")?.setValue(profile.id, forKey: "selectedProfileId")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
