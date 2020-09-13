//
//  UserSettings.swift
//  schema
//
//  Created by Victor Forsgren on 2020-09-10.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import Combine

final class UserSettings: ObservableObject {

    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @UserDefault("removeLunch", defaultValue: true)
    var removeLunch: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("InvertSchemaColor", defaultValue: true)
    var invertSchemaColor: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    
}
