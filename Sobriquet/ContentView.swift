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
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Student.getAllStudents()) var Students:FetchedResults<Student>
    @State private var showPicker = false
    
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
            InputFileUIView()
                .padding(.top, 30)
                .frame(width: 800)
            
            ComponentButtonsUIView().frame(width: 800)
            
            OutputFileView()
                .frame(width: 800)
                .padding(.leading, 30)
                .padding(.trailing, 30)
            
            Button(action: {
//                addStudent(eduid: 100, lastName: "Sorensen", firstName: "Brandon", middleName: "Loyal");
//                print(self.Students)
                print(self.managedObjectContext.coreDataIsEmpty)
            }) {
                Text("Start").frame(maxWidth: 100, maxHeight: 200)
            }.buttonStyle(StartButtonStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
