//
//  SettingsView.swift
//  schema
//
//  Created by Victor Forsgren on 2020-09-10.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = UserSettings()

    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $settings.removeLunch) {
                    Text("Ta bort \"Lunch\" från schemat")
                }
                Toggle(isOn: $settings.invertSchemaColor) {
                    Text("Invertera färg på schemabilden i mörkt läge")
                }
            }.listStyle(InsetGroupedListStyle())
                .navigationBarTitle("Inställningar")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
