//
//  Profile.swift
//  schema
//
//  Created by Victor Forsgren on 2020-09-22.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import RealmSwift

public class p_Profile: Object {
    @objc dynamic var classGUID: String?
    @objc dynamic var teacherGUID: String?
    @objc dynamic var signature: String?
    
    @objc dynamic var domain: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var schoolGUID: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var subTitle: String = ""
    
    convenience init(domain: String, schoolGUID: String, title: String, subTitle: String) {
        self.init()
        self.domain = domain
        self.schoolGUID = schoolGUID
        self.title = title
        self.subTitle = subTitle
        self.id = UUID().uuidString
    }
}
