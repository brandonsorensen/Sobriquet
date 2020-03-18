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
        
        self._allStudents = State(wrappedValue: asArray)
        
        self._viewableStudents = State(wrappedValue: Array(0..<asArray.count))
        self._loadRange = State(wrappedValue: 0..<min(DEFAULT_MAX_PER_ENROLLMENT_VIEW, asArray.count))
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
            
            EnrollmentFooter(loadRange: $loadRange)
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
                 .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3))
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
            TextField("Filter students.", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Filter", action: updateViewableIndex)
       }
    }
    
    private func updateViewableIndex() {
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
    @Binding var loadRange: Range<Int>
    
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
            Button(action: {}) {
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
        }
    }
}

//struct EnrollmentView_Previews: PreviewProvider {
//    @FetchRequest
//    static var previews: some View {
//        EnrollmentView(allStudents: )
//    }
//}
