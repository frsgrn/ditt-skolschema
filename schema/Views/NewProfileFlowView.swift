//
//  ProfileSelectFlow.swift
//  schema
//
//  Created by Victor Forsgren on 2020-02-06.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import SwiftUI

struct ChooseDomain: View {
    @Binding var showingDetail: Bool
    @State private var searchField: String = ""
    
    @State private var searchResults: [Domain] = []
    
    func getSearchResults () -> [Domain] {
        if (self.searchField == "") {
            return DomainList.domainList
        }
        else {
            DispatchQueue.main.async {
                self.searchResults = DomainList.domainList.filter {$0.name.lowercased().contains(self.filterPrivateChars(from:self.searchField.lowercased()))}
            }
            return self.searchResults
        }
    }
    
    func filterPrivateChars(from: String) -> String {
        let newString = from.replacingOccurrences(of: "å", with: "a").replacingOccurrences(of: "ä", with: "a").replacingOccurrences(of: "ö", with: "o")
        return newString
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $searchField, placeholder: "Sök bland domäner")
        List {
                ForEach(getSearchResults(), id: \.id) { domain in
                    Group {
                        NavigationLink(destination: ChooseSchool(showingDetail: self.$showingDetail, domain: domain)) {
                            VStack (alignment: .leading) {
                                Text(domain.name)
                            }
                        }
                    }
                }
            
            }.navigationBarTitle("Välj domän", displayMode: .inline)
    }
    }
}

struct ChooseSchool: View {
    @Binding var showingDetail: Bool
    let domain: Domain
    @State var schools: [School] = []
    
    func fetch() {
        Skola24Wrapper.getSchools(hostName: domain.url) { (schools, fetchError) in
            self.schools = schools ?? []
        }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(self.schools, id: \.id) { school in
                    NavigationLink(destination: ChooseSelection(showingDetail: self.$showingDetail, domain: self.domain, school: school)) {
                        VStack (alignment: .leading) {
                            Text(school.unitId)
                        }
                    }
                }
            }
        }.navigationBarTitle("Välj skola").onAppear(perform: fetch)
    }
}

struct ChooseSelection: View {
    @Binding var showingDetail: Bool
    @Environment(\.managedObjectContext) var moc
    
    @State private var selection = 0
    
    let domain: Domain
    let school: School
    
    @State var classes: [s24_Class]?
    @State var teachers: [Teacher]?
    
    @State var idInput = ""
    
    let options = ["Klass", "Lärare"]
    
    @EnvironmentObject var todayController: TodayController
    @EnvironmentObject var weekController: WeekController
    
    func fetch() {
        Skola24Wrapper.getClasses(school: self.school) { (classes, fetchError) in
            self.classes = classes ?? []
        }
        Skola24Wrapper.getTeachers(school: self.school) { (teachers, fetchError) in
            self.teachers = teachers ?? []
        }
    }
    
    func addClassProfile(s24_class: s24_Class) {
        /*let profile = Profile(context: self.moc)
        profile.id = UUID()
        profile.domain = self.domain.url
        profile.schoolGuid = self.school.unitGuid
        profile.classGuid = s24_class.groupGuid
        profile.title = s24_class.name
        profile.subTitle = school.unitId
        */
        //MARK: Experimental

        //let profile_ = Profile_(classGUID: s24_class.groupGuid, schoolGUID: self.school.unitGuid, teacherGUID: nil, domain: self.domain.url, id: UUID().uuidString, signature: nil, title: s24_class.name, subTitle: school.unitId)
        //ProfileManager.addProfile(profile: profile_)
        let profile = p_Profile(domain: self.domain.url, schoolGUID: self.school.unitGuid, title: s24_class.name, subTitle: school.unitId)
        profile.classGUID = s24_class.groupGuid
        ProfileManager.addProfile(profile: profile)
        ProfileManager.selectProfile(profile)
        
        clearAndLoad()
        
        //try? self.moc.save()
        self.showingDetail = false
        //ProfileController.setProfile(profile: profile)
        
    }
    
    func addTeacherProfile(teacher: Teacher) {
        /*let profile = Profile(context: self.moc)
        profile.id = UUID()
        profile.domain = self.domain.url
        profile.schoolGuid = self.school.unitGuid
        profile.teacherGuid = teacher.personGuid
        profile.title = teacher.firstName + " " + teacher.lastName
        profile.subTitle = school.unitId
        */
        //MARK: Experimental

        //let profile_ = Profile_(classGUID: nil, schoolGUID: self.school.unitGuid, teacherGUID: teacher.personGuid, domain: self.domain.url, id: UUID().uuidString, signature: nil, title: teacher.firstName + " " + teacher.lastName, subTitle: school.unitId)
        //ProfileManager.addProfile(profile: profile_)
        let profile = p_Profile(domain: self.domain.url, schoolGUID: self.school.unitGuid, title: teacher.firstName + " " + teacher.lastName, subTitle: school.unitId)
        profile.teacherGUID = teacher.personGuid
        ProfileManager.addProfile(profile: profile)
        ProfileManager.selectProfile(profile)
        
        clearAndLoad()
        
        //try? self.moc.save()
        self.showingDetail = false
        //ProfileController.setProfile(profile: profile)
    }
    
    func addIdProfile(id: String) {
        if (id.count == 0) {
            return
        }        
        /*let profile = Profile(context: self.moc)
        profile.id = UUID()
        profile.domain = self.domain.url
        profile.schoolGuid = self.school.unitGuid
        profile.signature = id
        profile.title = id
        profile.subTitle = school.unitId
        */
        //MARK: Experimental
        

        //let profile_ = Profile_(classGUID: nil, schoolGUID: self.school.unitGuid, teacherGUID: nil, domain: self.domain.url, id: UUID().uuidString, signature: id, title: id, subTitle: school.unitId)
        //ProfileManager.addProfile(profile: profile_)
        let profile = p_Profile(domain: self.domain.url, schoolGUID: self.school.unitGuid, title: id, subTitle: school.unitId)
        profile.signature = id
        ProfileManager.addProfile(profile: profile)
        ProfileManager.selectProfile(profile)
        
        clearAndLoad()
        
        // try? self.moc.save()
        self.showingDetail = false
        // ProfileController.setProfile(profile: profile)
        // UserDefaults.standard.set(profile.id?.uuidString, forKey: "selectedProfileId")
    }
    
    func clearAndLoad() {
            self.weekController.timetableJsonWeekLoads = []
            self.todayController.timetableObjectLoads = []
        
        self.weekController.load(ProfileManager.getSelectedProfile())
        self.todayController.load(ProfileManager.getSelectedProfile())
    }
    
    var body: some View {
        List {
            Section(header: Text("Välj ett personligt schema...")) {
                HStack {
                    TextField("Personnummer/id...", text: self.$idInput)
                    Spacer()
                    Button("Lägg till") {
                        self.addIdProfile(id: self.idInput)
                    }
                }
            }
            
            Section(header: Text("...eller från klass/lärare")) {
                Picker("Välj", selection: $selection) {
                    ForEach(0..<options.count) { i in
                        Text("\(self.options[i])").tag(i)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                if (selection == 0) {
                    if (self.classes == nil) {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                    else if (self.classes!.count == 0) {
                        Text("Det finns inga klasser")
                    }
                    else {
                    ForEach(self.classes!, id: \.id) { s24_class in
                        Button(action: {
                            self.addClassProfile(s24_class: s24_class)
                        }) {
                            VStack (alignment: .leading) {
                                Text(s24_class.name)
                            }
                        }.foregroundColor(Color(UIColor.label))
                    }
                    }
                }
                else if (selection == 1) {
                    if (self.teachers == nil) {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                    else if (self.teachers!.count == 0) {
                        Text("Det finns inga lärare")
                    }
                    else {
                    ForEach(self.teachers!, id: \.id) { teacher in
                        Button(action: {
                            self.addTeacherProfile(teacher: teacher)
                        }) {
                            VStack (alignment: .leading) {
                                HStack {
                                    Text(teacher.lastName + " ").font(.headline) + Text(teacher.firstName)
                                }
                                Text(teacher.id).foregroundColor(Color(UIColor.secondaryLabel))
                            }.foregroundColor(Color(UIColor.label))
                        }
                    }
                    }
                }
            }
        }.navigationBarTitle("Välj schema").listStyle(InsetGroupedListStyle()).onAppear(perform: fetch)
    }
}
