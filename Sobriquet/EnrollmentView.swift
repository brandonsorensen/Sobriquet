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
    @State var loadRange: Range<Int> = 0..<100
    


    var body: some View {
        VStack {
            Text("Enrollment").font(.subheadline)
            Filter()
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
            
            StudentScrollView(loadRange: $loadRange)
            
            EnrollmentFooter(loadRange: $loadRange)
        }
        
    }
    
}

struct StudentScrollView: View {
    
    @Binding var loadRange: Range<Int>
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(fetchRequest: Student.getAllStudents()) var Students:FetchedResults<Student>
    
    private let chunkSize = 100
    private let darkModeBackground = Color(red: 64 / 255,
                                           green: 65 / 255,
                                           blue: 67 / 255)
    private let textCornerRadius = CGFloat(7)
    
    var body: some View {
        ScrollView {
           VStack {
               
               ForEach(loadRange, id: \.self) { index in
                   EnrollmentCell(student: self.Students[index])
                .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3))
               }
               
               Spacer()
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
        .background(colorScheme == .dark ? darkModeBackground : Color.white)
            .cornerRadius(textCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: textCornerRadius)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
    private func loadMoreStudents() {
        self.loadRange = 0..<self.loadRange.upperBound + self.chunkSize
    }
}

struct Filter: View {
    @EnvironmentObject private var student: Student
    @State private var searchText: String = ""

    var body: some View {
        HStack {
            Text("Search:")
            Spacer()
            TextField("Filter students.", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Filter", action: {})
       }
    }
}

struct EnrollmentFooter: View {
    @FetchRequest(fetchRequest: Student.getAllStudents()) var Students:FetchedResults<Student>
    @Binding var loadRange: Range<Int>
    
    var body: some View {
        HStack {
            // Load All Button
            Button(action: { self.loadRange = 0..<self.Students.count }) {
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
                
                Image("upload-icon")
                .resizable()
                .renderingMode(.template)
                .frame(width: 20, height: 20, alignment: .leading)
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

struct EnrollmentView_Previews: PreviewProvider {
    static var previews: some View {
        EnrollmentFooter(loadRange: .constant(0..<100))
//        Filter()
    }
}
