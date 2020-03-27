//
//  EnrollmentView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/14/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

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
    
    @State var searchText: String = ""
    @Binding var studentManager: StudentManager
    @Binding var showWarningDialog: Bool
    
    static let labels: [String] = ["Last Name", "First Name", "EDUID"]
    static let alignmentType: [Alignment] = [.leading, .center, .trailing]

    var body: some View {
        VStack {
            Text("Enrollment").font(.subheadline)
            Filter(studentManager: $studentManager,
                   searchText: $searchText)
                .padding(.horizontal, 4)
            
            getHeader()
            
            Divider()
            
            StudentScrollView(studentManager: $studentManager)
        
            EnrollmentFooter(studentManager: $studentManager,
                             showWarningDialog: $showWarningDialog)
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
    @Environment(\.colorScheme) var colorScheme
    
    private let chunkSize = 100
    private let darkModeBackground = Color(red: 64 / 255,
                                           green: 65 / 255,
                                           blue: 67 / 255)
    private let textCornerRadius = CGFloat(7)
    private let fromEdgeRadius = CGFloat(5)
    
    var body: some View {
        List {
            ForEach(studentManager.getViewableIndex(), id: \.self) { index in
            EnrollmentCell(student: self.studentManager.atIndex(index: index))
                .padding(.horizontal, -3)
           }
        }
        .id(UUID())
        .background(colorScheme == .dark ? darkModeBackground : Color.white)
        .cornerRadius(textCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: textCornerRadius)
                .stroke(colorScheme == .dark ? Color.darkModeOutline : Color.outlineColor, lineWidth: 1)
        )
    }
}

struct Filter: View {
    @Binding var studentManager: StudentManager
    @Binding var searchText: String

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
            studentManager.updateViewable(indices: nil)
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
        
        studentManager.updateViewable(indices: filteredIndices)
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
    @Binding var studentManager: StudentManager
    @Binding var showWarningDialog: Bool
    
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
            Button(action: { self.showWarningDialog.toggle() }) {
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
    
    /*
    final class RunUpdateObserver: ObservableObject {
        var selection: Bool = false {
            didSet {
                if selection {
                    updateStudents()
                }
            }
        }

        // @Published var items = ["Jane Doe", "John Doe", "Bob"]
    }
 */
}



#if DEBUG
struct EnrollmentView_Previews: PreviewProvider {
    
    static var previews: some View {
//        EnrollmentView(studentManager: .constant(try! StudentManager()) )
        CsvWarningDialog(showWarningDialog: .constant(true))
    }
}
#endif
