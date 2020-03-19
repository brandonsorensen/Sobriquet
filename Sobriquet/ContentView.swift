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
                    .frame(minWidth: 700)
                Divider().padding(EdgeInsets(top: 20, leading: 0,
                                             bottom: 20, trailing: 0
                ))
                if showEnrollment {
                    EnrollmentView(allStudents: allStudents).frame(width: 333)
                    .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
                    .transition(.slide)
                }
            }
        }.frame(minHeight: 600)
    }
}

struct MainView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme
    @State private var showPicker = false
    @State var showSheetView = false
    @State var outputFormat: String = ""
    @State var eduidLocation: Int = 0
    @State var showLogo: Bool = true
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
                .disableAutocorrection(true)
        }
    }
    
    var body: some View {

        VStack {
            if showLogo {
                Image("sobriquet-text")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(-7))
                .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
                .frame(maxHeight: 200)
                .foregroundColor(colorScheme == .dark ? .orange : .black)
                .shadow(radius: 10)

            }
                        
            InputFileUIView(enrollmentViewState: $enrollmentViewState, eduidLocation: $eduidLocation)
                .padding(EdgeInsets(top: 30, leading: 30, bottom: 0, trailing: 30))

            ComponentButtonsUIView(outputFormat: $outputFormat)

            OutputFileView(outputFormat: $outputFormat)
                .padding(.leading, 30)
                .padding(.trailing, 30)

            Button(action: { self.showLogo.toggle() }) {
                Text("Start").frame(width: 200, height: 50)
            }.buttonStyle(StartButtonStyle())
            .disabled(eduidLocation == 0)

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
