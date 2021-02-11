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
        }.padding(.horizontal, 10)
        .offset(x: -8)
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
        
            EnrollmentFooter(
                studentManager: $studentManager,
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
//                .padding(.horizontal)
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
    @Binding var studentManager: StudentManager
    @Binding var showWarningDialog: Bool
    
    var body: some View {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yy h:mm a"
        
        return HStack {
            VStack(alignment: .leading) {
                Text("Last Updated:")
                Text(df.string(from: studentManager.mostRecentDate))
                    .font(.system(size: 10))
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
        }
    }
}

#if DEBUG
struct EnrollmentView_Previews: PreviewProvider {
    
    static var previews: some View {
        EnrollmentView(studentManager: .constant(try! StudentManager()),
                       showWarningDialog: .constant(true))
    }
}
#endif
