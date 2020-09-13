//
//  ContentView.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-11.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @EnvironmentObject var todayDelegate: TodayController
    
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @Environment(\.managedObjectContext) var moc
    
    @State private var showingDetailState = false
    
    @State private var showingWelcomeSheetState = true
    
    var body: some View {
        return Group {
            if (profiles.count > 0) {
                SchemaView()
            }
            else {
                NavigationView {
                    ChooseDomain(showingDetail: self.$showingDetailState)
                }.navigationViewStyle(StackNavigationViewStyle()).sheet(isPresented: self.$showingWelcomeSheetState) {
                    Text("Ditt Skolschema").font(.largeTitle).bold().padding(.top, 30)
                    HStack {
                    VStack (alignment: .leading) {
                        
                        HStack {
                            Image(systemName: "rectangle.stack").font(.largeTitle).padding(20).foregroundColor(Color(UIColor.systemBlue))
                            VStack(alignment: .leading) {
                                Text("Se direkt vad som händer idag").font(.headline)
                                Text("Appen analyserar ditt schema och berättar vad som händer härnäst.").font(.subheadline)
                            }
                        }.padding(.bottom, 20)
                        
                        HStack {
                            Image(systemName: "square.and.pencil").font(.largeTitle).padding(20).foregroundColor(Color(UIColor.systemYellow))
                            VStack(alignment: .leading) {
                                Text("Växla mellan flera scheman").font(.headline)
                                Text("Begränsa dig inte till ett enda schema, se allt du behöver veta ansträngningslöst.").font(.subheadline)
                            }
                        }.padding(.bottom, 20)
                        
                        HStack {
                            Image(systemName: "24.circle").font(.largeTitle).padding(20).foregroundColor(Color(UIColor.systemGreen))
                            VStack(alignment: .leading) {
                                Text("Hämta schemat direkt från Skola24").font(.headline)
                                Text("Klasschema, lärarschema och direkt från ditt personnummer.").font(.subheadline)
                            }
                        }.padding(.bottom, 20)
                        Spacer()
                        HStack (alignment: .center){
                            Spacer()
                        Button(action: {
                            self.showingWelcomeSheetState.toggle()
                        }) {
                            Text("Lägg till ditt första schema").bold().padding(15)
                            }.background(Color(UIColor.systemBlue)).foregroundColor(Color.white).cornerRadius(15)
                        Spacer()
                        }
                    }
                    }.padding(18)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
