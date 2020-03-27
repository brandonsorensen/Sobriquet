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
        let studentData: [String] = [student.lastName, student.firstName, String(student.eduid)]
        
        
        assert(studentData.count == EnrollmentView.alignmentType.count)
        
        return GeometryReader { geometry in
            HStack {
                ForEach(0..<studentData.count, id: \.self) { index in
                     Text(studentData[index].trimmingCharacters(in: .whitespacesAndNewlines))
                        .frame(width: geometry.size.width / CGFloat(studentData.count),
                               alignment: EnrollmentView.alignmentType[index])
                 }
            }
        }.padding(.horizontal, 6)
    }
}

struct EnrollmentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject private var student: Student
    
    @State var loadRange: Range<Int> //= 0..<DEFAULT_MAX_PER_ENROLLMENT_VIEW
    @State var searchText: String = ""
    @Binding var studentManager: StudentManager
    @State var viewableStudents: [Int]
    
    static let labels: [String] = ["Last Name", "First Name", "EDUID"]
    static let alignmentType: [Alignment] = [.leading, .center, .trailing]
    
    init(studentManager: Binding<StudentManager>) {
        self._studentManager = studentManager
        self._viewableStudents = State(wrappedValue: Array(0..<studentManager.wrappedValue.count))
        self._loadRange = State(wrappedValue: 0..<min(DEFAULT_MAX_PER_ENROLLMENT_VIEW, studentManager.wrappedValue.count))
    }

    var body: some View {
        
        
        return VStack {
            Text("Enrollment").font(.subheadline)
            Filter(studentManager: $studentManager, viewableStudents: $viewableStudents,
                   searchText: $searchText, loadRange: $loadRange)
                .padding(.horizontal, 4)
            
            getHeader()
            
            Divider()
            
            StudentScrollView(studentManager: $studentManager, loadRange: $loadRange,
                              viewableStudents: $viewableStudents)
        
            EnrollmentFooter(loadRange: $loadRange, studentManager: $studentManager,
                             viewableStudents: $viewableStudents)
        }
    }
    
    private func getHeader() -> some View {
        let labels = EnrollmentView.labels
        return GeometryReader { geometry in
            HStack {
                ForEach(0..<labels.count, id: \.self) { index in
                    Text(labels[index].trimmingCharacters(in: .whitespacesAndNewlines))
                        .frame(width: geometry.size.width / CGFloat(labels.count),
                               alignment: EnrollmentView.alignmentType[index])
                 }
            }
        }.frame(height: 20)
         .padding(.horizontal, 12)
    }
}

struct StudentScrollView: View {
    @Binding var studentManager: StudentManager
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
        List {
           VStack {
            // There were fewer than 100 elements returned by the search
            if viewableStudents.count < DEFAULT_MAX_PER_ENROLLMENT_VIEW {
               ForEach(viewableStudents, id: \.self) { index in
                EnrollmentCell(student: self.studentManager.atIndex(index: index))
                    .padding(.horizontal, -3)
               }
                
           // There were more than 100 elements returned by the search
            } else {
                ForEach(loadRange, id: \.self) { index in
                    EnrollmentCell(student: self.studentManager.atIndex( index: self.viewableStudents[index]))
                        .padding(.horizontal, -3)
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
    @Binding var studentManager: StudentManager
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
        if searchText.isEmpty {
            viewableStudents = Array(0..<studentManager.count)
            return
        }
        
        var filteredIndices = [Int]()
        var names: [String]
        var student: Student
        var keepStudent: Bool
        
        for index in 0..<studentManager.count {
            student = studentManager.atIndex(index: index)
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
    @State var mostRecentDate: Date = Student.getMostRecentDate()
    @State var isUniqueError = false
    @Binding var loadRange: Range<Int>
    @Binding var studentManager: StudentManager
    @Binding var viewableStudents: [Int]
    
    var body: some View {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yy h:mm a"
        
        return HStack {
            VStack(alignment: .leading) {
                Text("Last Updated:")
                Text(df.string(from: mostRecentDate)).font(.system(size: 10))
            }
            
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

            // Load All Button
            Button(action: { }) {
                Text("Load All")
                Image("refresh-icon")
                .resizable()
                .renderingMode(.template)
                .frame(width: 20, height: 20, alignment: .leading)
            }.buttonStyle(PlainButtonStyle())
            
            Spacer()
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
            if isUniqueError {
                isUniqueError = false
                return Alert(title: Text("Non-unique students"),
                             message: Text("Two or more students have the same EDUID."),
                             dismissButton: .default(Text("OK")))
            }
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
                            self.mostRecentDate = Date()
                            
                            newRoster.sort {
                                if $0.lastName != $1.lastName {
                                    return $0.lastName < $1.lastName
                                } else {
                                    return $0.firstName < $1.firstName
                                }
                            }
                            
                           try self.studentManager.update(students: newRoster)

                            
                        }
                    } catch CSVParser.ParserError.FileNotFound {
                        self.activeAlert = .FileNotFound
                        self.showAlert.toggle()
                    } catch CSVParser.ParserError.MalformedCSV{
                        self.activeAlert = .MalformedCSV
                        self.showAlert.toggle()
                    } catch StudentManager.StudentManagerError.NonUniqueElementError {
                        self.activeAlert = .Unknown
                        self.isUniqueError = true
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

#if DEBUG
struct EnrollmentView_Previews: PreviewProvider {
    
    static var previews: some View {
        EnrollmentView(studentManager: .constant(try! StudentManager()) )
    }
}
#endif
