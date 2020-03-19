//
//  EnrollmentView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/14/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

let DEFAULT_MAX_PER_ENROLLMENT_VIEW = 100

struct EnrollmentCell: View {
    var student: Student
    var columnSpacing = CGFloat(10)
    
    var body: some View {
        HStack(spacing: columnSpacing) {
            Text(student.lastName.trimmingCharacters(in: .whitespacesAndNewlines))
                .frame(alignment: .leading)
            Spacer()
            Text(student.firstName.trimmingCharacters(in: .whitespacesAndNewlines))
                .frame(alignment: .leading)
            Spacer()
            Text(String(student.eduid).trimmingCharacters(in: .whitespacesAndNewlines))
                .frame(alignment: .leading)
        }
    }
}

struct EnrollmentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject private var student: Student
    
    @State var loadRange: Range<Int> //= 0..<DEFAULT_MAX_PER_ENROLLMENT_VIEW
    @State var searchText: String = ""
    @State var allStudents: [Student]
    @State var viewableStudents: [Int]
    
    init(allStudents: FetchedResults<Student>) {
        var asArray = [Student]()
        
        for student in allStudents {
            asArray.append(student)
        }
        
        self.init(allStudents: asArray)
    }
    
    init(allStudents: [Student]) {
        self._allStudents = State(wrappedValue: allStudents)
        self._viewableStudents = State(wrappedValue: Array(0..<allStudents.count))
        self._loadRange = State(wrappedValue: 0..<min(DEFAULT_MAX_PER_ENROLLMENT_VIEW, allStudents.count))
    }

    var body: some View {
        VStack {
            Text("Enrollment").font(.subheadline)
            Filter(allStudents: $allStudents, viewableStudents: $viewableStudents,
                   searchText: $searchText, loadRange: $loadRange)
                .padding(EdgeInsets(top: 0, leading: 0,
                                    bottom: 3, trailing: 0))
            
            // Header
            HStack {
                Text("Last Name")
                Spacer()
                Text("First Name")
                Spacer()
                Text("EDUID")
            }
            
            Divider()
            
            StudentScrollView(allStudents: $allStudents, loadRange: $loadRange,
                              viewableStudents: $viewableStudents)
            
            EnrollmentFooter(loadRange: $loadRange, allStudents: $allStudents,
                             viewableStudents: $viewableStudents)
        }
    }
}

struct StudentScrollView: View {
    @Binding var allStudents: [Student]
    @Binding var loadRange: Range<Int>
    @Binding var viewableStudents: [Int]
    @Environment(\.colorScheme) var colorScheme
    
    private let chunkSize = 100
    private let darkModeBackground = Color(red: 64 / 255,
                                           green: 65 / 255,
                                           blue: 67 / 255)
    private let textCornerRadius = CGFloat(7)
    private let fromEdgeRadius = CGFloat(5)
    
    var body: some View {
        ScrollView {
           VStack {
            // There were fewer than 100 elements returned by the search
            if viewableStudents.count < DEFAULT_MAX_PER_ENROLLMENT_VIEW {
               ForEach(viewableStudents, id: \.self) { index in
                    EnrollmentCell(student: self.allStudents[index])
                .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3))
               }
                
           // There were more than 100 elements returned by the search
            } else {
                ForEach(loadRange, id: \.self) { index in
                    EnrollmentCell(student: self.allStudents[self.viewableStudents[index]])
                        .padding(EdgeInsets(top: 0, leading: self.fromEdgeRadius,
                                            bottom: 0, trailing: self.fromEdgeRadius))
                }
            }
            
            Spacer()
            if self.viewableStudents.count > self.loadRange.upperBound {
                Button(action: loadMoreStudents) {
                    Text("Load More")
                }
                .onAppear {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 300)) {
                        self.loadMoreStudents()
                    }
                }
            }
           }
        }
        .background(colorScheme == .dark ? darkModeBackground : Color.white)
            .cornerRadius(textCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: textCornerRadius)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
    private func loadMoreStudents() {
        self.loadRange = 0..<min(self.loadRange.upperBound + self.chunkSize,
                                 self.viewableStudents.count)
    }
}

struct Filter: View {
    @Binding var allStudents: [Student]
    @Binding var viewableStudents: [Int]
    @Binding var searchText: String
    @Binding var loadRange: Range<Int>

    var body: some View {
        HStack {
            Text("Search:")
            Spacer()
            TextField("Filter students.", text: $searchText, onCommit: updateViewableIndex)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Filter", action: updateViewableIndex)
       }
    }
    
    private func updateViewableIndex() {
        if searchText.isEmpty { return }
        
        var filteredIndices = [Int]()
        var names: [String]
        var student: Student
        var keepStudent: Bool
        
        for index in 0..<allStudents.count {
            student = allStudents[index]
            keepStudent = false
            names = searchText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces)
        
            for name in names {
                if containsString(student: student, text: name) {
                    keepStudent = true
                }
            }
            
            if keepStudent {
                filteredIndices.append(index)
            }
        }
        
        loadRange = 0..<DEFAULT_MAX_PER_ENROLLMENT_VIEW
        viewableStudents = filteredIndices
    }
    
    private func containsString(student: Student, text: String) -> Bool {
        let lower = text.lowercased()
        var contains = false
        
        contains = (
            student.lastName.lowercased().contains(lower) ||
                student.firstName.lowercased().contains(lower) ||
                String(student.eduid).lowercased().contains(lower)
        )
        
        if let middle = student.middleName {
            contains = contains || middle.lowercased().contains(text)
        }
        
        return contains
    }
}

struct EnrollmentFooter: View {
    @State var showAlert: Bool = false
    @State var activeAlert: CSVParser.ParserError = .Unknown
    @Binding var loadRange: Range<Int>
    @Binding var allStudents: [Student]
    @Binding var viewableStudents: [Int]
    
    var body: some View {
        HStack {
            // Load All Button
            Button(action: { }) {
                Text("Load All")
                Image("refresh-icon")
                .resizable()
                .renderingMode(.template)
                .frame(width: 20, height: 20, alignment: .leading)
            }.buttonStyle(PlainButtonStyle())
            
            Spacer()

            // Update DB button
            Button(action: updateStudents) {
                VStack {
                    Text("Update")
                    Text("Database")
                }.offset(x: 3)
                
                Image("overwrite-icon")
                .resizable()
                .renderingMode(.template)
                .frame(width: 30, height: 30, alignment: .leading)
            }.buttonStyle(PlainButtonStyle())
                .offset(x: -5)
            
            Spacer()
            
            Button(action: {}) {
                VStack {
                    Text("Add")
                    Text("Students")
                }.offset(x: 3)
                
                Image("plus-icon")
                .resizable()
                .renderingMode(.template)
                .frame(width: 20, height: 20)
            }.buttonStyle(PlainButtonStyle())
        }.alert(isPresented: $showAlert) { return alertSwitch(activeAlert: activeAlert) }
    }
    
    func alertSwitch(activeAlert: CSVParser.ParserError) -> Alert {
        switch activeAlert {
        case .FileNotFound:
            return Alert(title: Text("File Not Found"), message: Text("Could not find file."),
                         dismissButton: .default(Text("OK")))
        case .MalformedCSV:
            return Alert(title: Text("Malformed CSV"),
                         message: Text("Ensure the CSV file has the right encoding and format: Last Name, First Name, Middle Name, EDUID"),
                         dismissButton: .default(Text("OK")))
        case .Unknown:
            return Alert(title: Text("Unknown error."))
        }
    }
    
    func fileDialog() -> NSOpenPanel {
        let fileDialog = NSOpenPanel()

        fileDialog.prompt = "Select path"
        fileDialog.worksWhenModal = true
        fileDialog.canChooseDirectories = false
        fileDialog.canChooseFiles = true
        fileDialog.canCreateDirectories = false
        fileDialog.allowsMultipleSelection = false
        
        return fileDialog
    }
    
    func updateStudents() {
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        if !moc.coreDataIsEmpty {
            do {
                try Student.deleteAllStudents()
            } catch {
                self.activeAlert = .Unknown
                self.showAlert.toggle()
            }
            
        }
        
        var newRoster = [Student]()
        
        let fileDialog = self.fileDialog()
        fileDialog.begin { response in
            if response == .OK {
                let selectedPath = fileDialog.url!.path
                if !selectedPath.isEmpty {
                    do {
                        if let fields: [CSVFields] = try CSVParser.readCSV(csvURL: selectedPath, encoding: .utf8,
                                                                           inBundle: false) {
                            for field in fields {
                                let student = Student(context: moc)
                                student.eduid = field.eduid
                                student.lastName = field.lastName
                                student.firstName = field.firstName
                                student.middleName  = field.middleName
                                student.dateAdded = Date()
                                
                                try moc.save()
                                
                                newRoster.append(student)
                            }
                            
                            self.loadRange = 0..<min(DEFAULT_MAX_PER_ENROLLMENT_VIEW, newRoster.count)
                            self.viewableStudents = Array(0..<newRoster.count)
                            self.allStudents = newRoster
                        }
                    } catch CSVParser.ParserError.FileNotFound {
                        self.activeAlert = .FileNotFound
                        self.showAlert.toggle()
                    } catch CSVParser.ParserError.MalformedCSV{
                        self.activeAlert = .MalformedCSV
                        self.showAlert.toggle()
                    } catch {
                        self.activeAlert = .Unknown
                        self.showAlert.toggle()
                    }
                }
            }
            fileDialog.close()
        }
    }
}

//struct EnrollmentView_Previews: PreviewProvider {
//    @FetchRequest
//    static var previews: some View {
//        EnrollmentView(allStudents: )
//    }
//}
