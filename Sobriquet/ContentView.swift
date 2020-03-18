//
//  ContentView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI
import AppKit
import CoreData


struct ContentView: View {
    @State var showEnrollment: Bool = false
    @FetchRequest(fetchRequest: Student.getAllStudents()) var allStudents: FetchedResults<Student>
    
    var body: some View {
        HStack {
            HStack {
                MainView(enrollmentViewState: $showEnrollment)
                    .frame(minWidth: 600)
                Divider().padding(EdgeInsets(top: 20, leading: 0,
                                             bottom: 20, trailing: 0
                ))
                if showEnrollment {
                    EnrollmentView(allStudents: allStudents).frame(width: 333)
                    .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
                    .transition(.slide)
                }
            }
        }
    }
}

struct MainView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var showPicker = false
    @State var showSheetView = false
    @State var outputFormat: String = ""
    @Binding var enrollmentViewState: Bool
    
    struct StartButtonStyle: ButtonStyle {
        @State private var isPressed = false
        
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .foregroundColor(configuration.isPressed ? Color.blue : Color.white)
                .background(configuration.isPressed ? Color.white : Color.blue)
                .scaleEffect(isPressed ? 1.4 : 1.0)
                .cornerRadius(6.0)
                .padding()
        }
    }
    
    var body: some View {

        VStack {
//            Image("AppIcon.appiconset.png")
            InputFileUIView(enrollmentViewState: $enrollmentViewState)
                .padding(EdgeInsets(top: 30, leading: 30, bottom: 0, trailing: 30))

            ComponentButtonsUIView(outputFormat: $outputFormat)

            OutputFileView(outputFormat: $outputFormat)
                .padding(.leading, 30)
                .padding(.trailing, 30)

            Button(action: {}) {
                Text("Start").frame(width: 200, height: 50)
            }.buttonStyle(StartButtonStyle())

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
