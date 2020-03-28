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



#if DEBUG
let INPUT_DEFAULT = "/Users/Brandon/Library/Mobile Documents/com~apple~CloudDocs/Programming/Projects/Sobriquet/test-files"
let OUTPUT_PATH_DEFAULT = "/Users/Brandon/Library/Mobile Documents/com~apple~CloudDocs/Programming/Projects/Sobriquet/test-output"
let OUTPUT_FORMAT_DEFAULT = "%Last Name%_%First Name%_%eduid%_test"
let DEFAULT_PICKER_SELECTION = 1

#else

let INPUT_DEFAULT = ""
let OUTPUT_PATH_DEFAULT = ""
let OUTPUT_FORMAT_DEFAULT = ""
let DEFAULT_PICKER_SELECTION = 0

#endif

struct ContentView: View {
    @State var studentManager: StudentManager
    @State var copyManager: CopyManager = CopyManager()
    @State var showEnrollment: Bool = false
    @State var showCsvWarning: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: AlertType = .Unknown
    @State var showRenameView = false
    @State var currentFile: Double = 0
    
    init() {
        do {
            try self._studentManager = State(wrappedValue: StudentManager())
        } catch StudentManager.StudentManagerError.NonUniqueElementError {
            self._studentManager = try! State(wrappedValue: StudentManager(students: [Student]()))
            self._alertType = State(wrappedValue: .NonUniqueStudent)
            self._showAlert = .init(wrappedValue: true)
            try! (NSApplication.shared.delegate as! AppDelegate).loadDefaultEnrollment()
        } catch {
            self._studentManager = try! State(wrappedValue: StudentManager(students: [Student]()))
            self._alertType = State(wrappedValue: .Unknown)
            self._showAlert = .init(wrappedValue: true)
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                HStack {
                    MainView(enrollmentViewState: $showEnrollment, studentManager: $studentManager,
                             showRenameView: $showRenameView, copyManager: $copyManager, showAlert: $showAlert, alertType: $alertType)
                        .frame(minWidth: 900)
                    Divider().padding(EdgeInsets(top: 20, leading: 0,
                                                 bottom: 20, trailing: 0
                    ))
                    if showEnrollment {
                        EnrollmentView(
                            studentManager: $studentManager,
                            showWarningDialog: $showCsvWarning)
                            .frame(width: 333)
                        .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
                        .transition(.slide)
                    }
                }
            }.frame(minHeight: 650)
                .alert(isPresented: $showAlert) {
                    return errorSwitch(error: alertType)
            }.allowsHitTesting(!(showRenameView || showCsvWarning))
                .overlay(Color.black.opacity(showRenameView ? 0.1 : 0))
            
            if showCsvWarning {
                CsvWarningDialog(showWarningDialog: $showCsvWarning,
                                 studentManager: $studentManager)
                    .clipped()
                    .shadow(radius: 5)
                    .offset(y: -1)
                    .transition(.move(edge: .top))
                    .animation(.spring())
            }
            
            if showRenameView {
                RenameView(showView: $showRenameView, currentProgress: $currentFile,
                           copyManager: $copyManager)
                    .transition(.move(edge: .top))
                    .animation(.spring())
            }
        }

    }
    
    enum AlertType {
        case BadOutputDirectory
        case BadInputDirectory
        case NoComponentError
        case BadDefaultCsv
        case NonUniqueStudent
        case Unknown
    }
    
    func errorSwitch(error: AlertType) -> Alert {
        switch error {
        case .BadOutputDirectory:
            return Alert(title: Text("Output Directory Error"),
                         message: Text("The provided output directory does not exist."),
                         dismissButton: .default(Text("OK")))
        case .BadInputDirectory:
            return Alert(title: Text("Input Directory Error"),
                         message: Text("The provided input directory does not exist."),
                         dismissButton: .default(Text("OK")))
        case .BadDefaultCsv:
            return Alert(title: Text("Corrupted internal CSV file"),
                  message: Text("The default CSV file has been corrupted."), dismissButton: .default(Text("OK")))
        case .NoComponentError:
            return Alert(title: Text("No Format Component"),
                  message: Text("The output format must contain at least one of the provided components."), dismissButton: .default(Text("OK")))
        case .NonUniqueStudent:
            let message = Text("At least two students in the data base have the same EDUID. Resorting to default data base.")
            return Alert(title: Text("Non unique student"),
                         message: message,
                         dismissButton: .default(Text("OK")))
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
    @State var inputPath: String = INPUT_DEFAULT
    @State var outputPath: String = OUTPUT_PATH_DEFAULT
    @State var outputFormat: String = OUTPUT_FORMAT_DEFAULT
    @State var extensionText: String = ".pdf"
    @State var eduidLocation: Int = DEFAULT_PICKER_SELECTION
    @State var showLogo: Bool = true
    @State var currentFile: Double = 0
    @Binding var enrollmentViewState: Bool
    @Binding var studentManager: StudentManager
    @Binding var showRenameView: Bool
    @Binding var copyManager: CopyManager
    @Binding var showAlert: Bool
    @Binding var alertType: ContentView.AlertType
    
    let edgeSpace = CGFloat(30)
    
    struct StartButtonStyle: ButtonStyle {
        @State private var isPressed = false
        @Binding var inputPath: String
        @Binding var outputPath: String
        @Binding var outputFormat: String
        @Binding var eduidLocation: Int
        
        var enabled: Bool {
            return eduidLocation != 0 &&
                       !outputPath.isEmpty &&
                       !outputFormat.isEmpty &&
                       !inputPath.isEmpty
        }
        
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .foregroundColor(Color.white)
                .background(Color.blue)
                .overlay(Color.black.opacity(configuration.isPressed ? 0.2 : 0))
                .overlay(Color.gray.opacity(enabled ? 0 : 0.4))
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

            OutputFileView(outputPath: $outputPath, outputFormat: $outputFormat, extensionText: $extensionText)
                .padding(EdgeInsets(top: 0, leading: edgeSpace, bottom: 0, trailing: edgeSpace))

            Button(action: activateRenameView ) {
                Text("Start").frame(width: 200, height: 50)
            }.buttonStyle(StartButtonStyle(
                inputPath: $inputPath,
                outputPath: $outputPath,
                outputFormat: $outputFormat,
                eduidLocation: $eduidLocation))
            .disabled(!enableStartButton)
        }
    }
    
    var enableStartButton: Bool {
        return eduidLocation != 0 &&
            !outputPath.isEmpty &&
            !outputFormat.isEmpty &&
            !inputPath.isEmpty
    }
    
    func activateRenameView() {
        // If the output directory doesn't exist
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: outputPath,
                                           isDirectory: &isDir) {
            self.alertType = .BadOutputDirectory
            self.showAlert.toggle()
            return
        }
        
        do {
            let newOperations = try CopyManager.loadCopyOperations(inputPath: self.inputPath,
                                                                    outputPath: self.outputPath,
                                                                    outputFormat: self.outputFormat + self.extensionText,
                                                                    studentManager: self.studentManager,
                                                                    inFileName: self.eduidLocation == 1)
            self.copyManager.update(operations: newOperations)
            
            self.showRenameView.toggle()
        } catch CopyOperation.CopyError.NoOutputComponentsError {
            self.alertType = .NoComponentError
            self.showAlert.toggle()
        } catch CopyOperation.CopyError.BadInputDir {
            self.alertType = .BadInputDirectory
            self.showAlert.toggle()
        } catch {
            self.alertType = .Unknown
            self.showAlert.toggle()
        }
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
