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
    @State var allStudents: [Student] = [Student]()
    @State var studentMap = Dictionary<Int, Student>()
    @State var showAlert: Bool = false
    @State var alertType: AlertType = .Unknown
    @State var showRenameView = true
    @State var currentFile: Double = 50
    @State var numFiles: Double = 100
    
    init() {
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        let moc = appDelegate.persistentContainer.viewContext
        let studentRequest = Student.getAllStudents()
        var map = Dictionary<Int, Student>()
        
        do {
            self._allStudents = State(wrappedValue: try moc.fetch(studentRequest))
        } catch {
            do {
                try appDelegate.loadDefaultEnrollment()
            } catch CSVParser.ParserError.MalformedCSV {
                self.alertType = .BadDefaultCsv
                self.showAlert.toggle()
            } catch {
                self.alertType = .Unknown
                self.showAlert.toggle()
            }
        }
//        allStudents = students
        
        for student in allStudents {
            map[student.eduid] = student
        }
        
        self._studentMap = State(wrappedValue: map)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                HStack {
                    MainView(enrollmentViewState: $showEnrollment, studentMap: $studentMap, showRenameView: $showRenameView)
                        .frame(minWidth: 700)
                    Divider().padding(EdgeInsets(top: 20, leading: 0,
                                                 bottom: 20, trailing: 0
                    ))
                    if showEnrollment {
                        EnrollmentView(allStudents: $allStudents).frame(width: 333)
                        .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
                        .transition(.slide)
                    }
                }
            }.frame(minHeight: 600)
                .alert(isPresented: $showAlert) {
                    return errorSwitch(error: alertType)
            }.allowsHitTesting(!showRenameView)
                .overlay(Color.black.opacity(showRenameView ? 0.1 : 0))
            
            if showRenameView {
                RenameView(showView: $showRenameView, currentProgress: $currentFile, numFiles: $numFiles)
                    .transition(.move(edge: .top))
                    .animation(.default)
            }
        }

    }
    
    enum AlertType {
        case BadDefaultCsv
        case Unknown
    }
    
    func errorSwitch(error: AlertType) -> Alert {
        switch error {
        case .BadDefaultCsv:
            return Alert(title: Text("Corrupted internal CSV file"),
                  message: Text("The default CSV file has been corrupted."), dismissButton: .default(Text("OK")))
        default:
            return Alert(title: Text("Unknown error."))
        }
    }
}

struct MainView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme
    @State private var showPicker = false
    @State var showSheetView = false
    @State var inputPath: String = ""
    @State var outputPath: String = ""
    @State var outputFormat: String = ""
    @State var eduidLocation: Int = 0
    @State var showLogo: Bool = true
    @State var currentFile: Double = 50
    @State var numFiles: Double = 100
    @State var renameInProgress: Bool = true
    @Binding var enrollmentViewState: Bool
    @Binding var studentMap: Dictionary<Int, Student>
    @Binding var showRenameView: Bool
    
    let edgeSpace = CGFloat(30)
    
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
                        
            InputFileUIView(enrollmentViewState: $enrollmentViewState, eduidLocation: $eduidLocation,
                            inputPath: $inputPath)
                .padding(EdgeInsets(top: 30, leading: edgeSpace, bottom: 0, trailing: edgeSpace))

            ComponentButtonsUIView(outputFormat: $outputFormat, isDeactivated: $showRenameView)

            OutputFileView(outputPath: $outputPath, outputFormat: $outputFormat)
                .padding(EdgeInsets(top: 0, leading: edgeSpace, bottom: 0, trailing: edgeSpace))

            Button(action: {
                self.showRenameView.toggle()
                self.renameInProgress.toggle()
            } ) {
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
