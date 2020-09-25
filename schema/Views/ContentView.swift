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
    @EnvironmentObject var todayController: TodayController
    @EnvironmentObject var weekController: WeekController
    
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @Environment(\.managedObjectContext) var moc
    
    @State private var showingDetailState = false
    
    @State private var showingWelcomeSheetState = true
    
    var body: some View {
        return Group {
            if (ProfileManager.getProfiles().count > 0) {
                SchemaView().onAppear {
                    //let profile = self.profiles.first(where: {$0.id!.uuidString == UserDefaults.standard.string(forKey: "selectedProfileId")})
                    todayController.load(ProfileManager.getSelectedProfile())
                    weekController.selectedWeek = weekController.getCurrentWeek()
                    weekController.load(ProfileManager.getSelectedProfile())
                }
            }
            else {
                NavigationView {
                    ChooseDomain(showingDetail: self.$showingDetailState).onAppear {
                        if (self.profiles.count > 0 && ProfileManager.getProfiles().count == 0) {
                            for profileOld in profiles {
                                //profileOld.id.uuidString
                                //let profile_ = Profile_(classGUID: profileOld.classGuid, schoolGUID: profileOld.schoolGuid ?? "", teacherGUID: profileOld.teacherGuid, domain: profileOld.domain ?? "", id: profileOld.id!.uuidString, signature: profileOld.signature, title: profileOld.title ?? "", subTitle: profileOld.subTitle ?? "")
                                let prof = p_Profile(domain: profileOld.domain!, schoolGUID: profileOld.schoolGuid!, title: profileOld.title!, subTitle: profileOld.subTitle!)
                                prof.teacherGUID = profileOld.teacherGuid
                                prof.classGUID = profileOld.classGuid
                                prof.signature = profileOld.signature
                                ProfileManager.addProfile(profile: prof)
                                //profileOld.delete
                                moc.delete(profileOld)
                                try? moc.save()
                            }
                            ProfileManager.selectProfile(ProfileManager.getProfiles()[0])
                        }
                    }
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
