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
    
    @State private var results: [Domain] = []
    
    var body: some View {
        VStack {
        List {
            Section(header: Text("Domäner i alfabetisk ordning")) {
                ForEach(Skola24Wrapper.domainList, id: \.id) { domain in
                    Group {
                        //if (self.isMatching(domain: domain)) {
                        NavigationLink(destination: ChooseSchool(showingDetail: self.$showingDetail, domain: domain)) {
                            VStack (alignment: .leading) {
                                Text(domain.name)
                            }
                        }
                    //}
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
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @Environment(\.managedObjectContext) var moc
    
    @State private var selection = 0
    
    let domain: Domain
    let school: School
    
    @State var classes: [s24_Class] = []
    @State var teachers: [Teacher] = []
    
    @State var idInput = ""
    
    let options = ["Klass", "Lärare", "Eget"]
    
    func fetch() {
        Skola24Wrapper.getClasses(school: self.school) { (classes, fetchError) in
            self.classes = classes ?? []
        }
        Skola24Wrapper.getTeachers(school: self.school) { (teachers, fetchError) in
            self.teachers = teachers ?? []
        }
    }
    
    func addClassProfile(s24_class: s24_Class) {
        let profile = Profile(context: self.moc)
        profile.id = UUID()
        profile.domain = self.domain.url
        profile.schoolGuid = self.school.unitGuid
        profile.classGuid = s24_class.groupGuid
        profile.title = s24_class.name
        profile.subTitle = school.unitId
        try? self.moc.save()
        self.showingDetail = false
        UserDefaults.standard.set(profile.id?.uuidString, forKey: "selectedProfileId")
    }
    
    func addTeacherProfile(teacher: Teacher) {
        let profile = Profile(context: self.moc)
        profile.id = UUID()
        profile.domain = self.domain.url
        profile.schoolGuid = self.school.unitGuid
        profile.teacherGuid = teacher.personGuid
        profile.title = teacher.firstName + " " + teacher.lastName
        profile.subTitle = school.unitId
        try? self.moc.save()
        self.showingDetail = false
        UserDefaults.standard.set(profile.id?.uuidString, forKey: "selectedProfileId")
    }
    
    func addIdProfile(id: String) {
        if (id.count == 0) {
            return
        }        
        let profile = Profile(context: self.moc)
        profile.id = UUID()
        profile.domain = self.domain.url
        profile.schoolGuid = self.school.unitGuid
        profile.signature = id
        profile.title = id
        profile.subTitle = school.unitId
        try? self.moc.save()
        self.showingDetail = false
        UserDefaults.standard.set(profile.id?.uuidString, forKey: "selectedProfileId")
    }
    
    var body: some View {
        Group {
            Picker("Välj", selection: $selection) {
                ForEach(0..<options.count) { i in
                    Text("\(self.options[i])").tag(i)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            if (selection == 0) {
                List {
                ForEach(self.classes, id: \.id) { s24_class in
                    Button(action: {
                        self.addClassProfile(s24_class: s24_class)
                    }) {
                        VStack (alignment: .leading) {
                            Text(s24_class.name)
                        }
                    }
                }
                }
            }
            else if (selection == 1) {
                List {
                ForEach(self.teachers, id: \.id) { teacher in
                    Button(action: {
                        self.addTeacherProfile(teacher: teacher)
                    }) {
                        VStack (alignment: .leading) {
                            HStack {
                                Text(teacher.lastName + " ").font(.headline) + Text(teacher.firstName)
                            }
                            Text(teacher.id)
                        }
                    }
                }
                }
            }
            else if (selection == 2) {
                List {
                    Section(header: Text("Välj ditt personliga schema")) {
                TextField("Personnummer/id...", text: self.$idInput)
                Button("Lägg till") {
                    self.addIdProfile(id: self.idInput)
                }
                    }
                }.listStyle(GroupedListStyle())
            }
        }.onAppear(perform: fetch).navigationBarTitle("Välj schema från")
    }
}
/*

struct SearchBar: UIViewRepresentable {

    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar,
                      context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

 */
