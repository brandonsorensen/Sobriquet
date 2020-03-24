//
//  RenameView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/21/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

struct RenameView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var displayText: String = ""
    @State var selectedFilter = 0
    @State var executed = false
    @State var overwrite = false
    @Binding var showView: Bool
    @Binding var currentProgress: Double
    @Binding var numFiles: Double
    @Binding var copyManager: CopyManager
    
    private static let cornerRadius = CGFloat(7)
    private static let buttonWidth = CGFloat(100)
    
    static let sheetWidth = CGFloat(600)
    static let safeWidth = sheetWidth * 0.88
    
    private static let lightModeBackground = Color(
        red: 235 / 255,
        green: 235 / 255,
        blue: 235 / 255
    )
    
    private static let darkModeBackground = Color(
        red: 53 / 255,
        green: 54 / 255,
        blue: 55 / 255
    )
    
    private static let darkModeTextViewBackground = Color(
        red: 64 / 255,
        green: 65 / 255,
        blue: 67 / 255
    )
    
    private static let darkModeOutline = Color(
        red: 77 / 255,
        green: 78 / 255,
        blue: 80 / 255
    )
    
    private static let outlineColor = Color(
        red: 206 / 255,
        green: 206 / 255,
        blue: 206 / 255
    )
    
    var body: some View {
        
        VStack {
            Spacer()
            Header()
            RenameOperations(manager: $copyManager, executed: $executed)
            
            ProgressBar(value: $currentProgress, maxValue: $numFiles,
                        backgroundColor: colorScheme == .dark ? RenameView.darkModeTextViewBackground : Color.white)
                .frame(width: RenameView.safeWidth)
            
            Spacer()
            Footer(displayText: $displayText, selectedFilter: $selectedFilter, executed: $executed,
                   overwrite: $overwrite, copyManager: $copyManager, showView: $showView)
            Spacer()
            
        }.frame(width: RenameView.sheetWidth, height: 600)
            .background(colorScheme == .dark ? RenameView.darkModeBackground : RenameView.lightModeBackground)
            .border(colorScheme == .dark ? RenameView.darkModeOutline : RenameView.outlineColor, width: 1)
            .clipped()
            .shadow(radius: 3)
            .offset(y: -1)  // Hides top shadow
    }
    
    struct Header: View {
        let columns = [
                   "Student", "Output Preview", "Status"
               ]
        static let spacingQuotient = CGFloat(4.2)
        static let sizeRatio = CGFloat(0.6)
        
        var body: some View {
            VStack {
                Text("Rename Files").font(.headline)
                Spacer()
                Divider().frame(width: RenameView.safeWidth)
                HStack {
                    ForEach(0..<self.columns.count) { index in
                        Text(self.columns[index]).frame(width: RenameView.safeWidth / Header.getQuotientForIndex(index: index))
                        if index != self.columns.count - 1 {
                            Divider()
                        }
                    }
                }
                .frame(width: RenameView.safeWidth, height: 15, alignment: .top)
            }.offset(y: 2)
        }
        
        static func getQuotientForIndex(index: Int) -> CGFloat {
            return CGFloat(index != 1 ? Header.spacingQuotient : Header.spacingQuotient * Header.sizeRatio)
        }
    }
    
    private struct RenameOperations: View {
        @Environment(\.colorScheme) var colorScheme
        @Binding var manager: CopyManager
        @Binding var executed: Bool
        
        var body: some View {
            List {
                if self.manager.isEmpty {
                    Text("\nRename operations will display here.")
                        .foregroundColor(.gray)
                        .frame(alignment: .center)
                } else {
                    ForEach(0..<self.manager.count, id: \.self) { index in
                        RenameOperationCell(currentIndex: index, op: self.manager.getOperation(at: index))
                    }
                }
            }
            .padding(.horizontal, -9)
            .frame(width: RenameView.safeWidth, height: 470)
            .background(colorScheme == .dark ? RenameView.darkModeTextViewBackground : Color.white)
            .cornerRadius(RenameView.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: RenameView.cornerRadius)
                    .stroke(colorScheme == .dark ? RenameView.darkModeOutline : RenameView.outlineColor, lineWidth: 1)
            )
        }
    }
    
    private struct Footer: View {
        @Binding var displayText: String
        @Binding var selectedFilter: Int
        @Binding var executed: Bool
        @Binding var overwrite: Bool
        @Binding var copyManager: CopyManager
        @Binding var showView: Bool
        
        private struct ExecuteButtonStyle: ButtonStyle {
            @State private var isPressed = false
            
            static let cornerRadius = CGFloat(4.0)
            
            func makeBody(configuration: Self.Configuration) -> some View {
                configuration.label
                    .frame(width: 70, height: 20)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .overlay(Color.black.opacity(configuration.isPressed ? 0.15 : 0))
                    .cornerRadius(ExecuteButtonStyle.cornerRadius)
                    .disableAutocorrection(true)
                    .animation(.none)
            }
        }
        
        private let filters = [
            "-- Select Filter --",
            "Successfully copied",
            "File Not Found",
            "File already exists",
            "File overwritten"
        ]
        
        var body: some View {
            HStack {
                Picker(selection: $selectedFilter, label:
                Text("")) {
                    ForEach(0..<filters.count, id: \.self) {
                        Text(self.filters[$0])
                    }
                }.frame(width: 200, alignment: .leading)
                    .offset(x: -9)  // Make up for empty label
                    .disabled(!executed)
                
                Toggle(isOn: $overwrite) {
                    Text("Overwrite existing files")
                }
                
                Spacer()
                Button(action: { self.displayText = ""; self.showView.toggle() }) { Text("Cancel") }.frame(alignment: .center)
                Button(action: {
                    self.copyManager.updateStatuses(to: .Copied)
                    self.executed.toggle()
//                    self.copyManager.clearAll()
                    }) { Text("Execute") }
                .buttonStyle(ExecuteButtonStyle())
                .disabled(executed)
                
            }.padding(.bottom, 10)
                .frame(width: RenameView.safeWidth)
        }
    }
}

struct RenameOperationCell: View {
    
    private static let edgePadding = CGFloat(10)
    private static let nViews = CGFloat(3)
    private static var centerWidth: CGFloat {
        RenameView.safeWidth /  RenameView.Header.getQuotientForIndex(index: 1)
    }
    private static var edgeWidth: CGFloat {
        RenameView.safeWidth / RenameView.Header.getQuotientForIndex(index: 0)
    }
    static let lightGray = Color(red: 249 / 255, green: 250 / 255, blue: 250 / 255)
    private let dividerInsets = EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
    
    private let color: Color
    private var studentFile: StudentFile { return operation.getStudentFile() }
    private var student: Student { return studentFile.getStudent() }
    
    @ObservedObject private var operation: CopyOperation
    @State var hovered: Bool = false
    
    init(currentIndex: Int, op: CopyOperation) {
        self.color = currentIndex % 2 == 0 ? Color.white : RenameOperationCell.lightGray
        self.operation = op
    }
    
    var body: some View {
        
        HStack {
            ZStack {
                StudentNameView(student: student)
                    .frame(width: RenameOperationCell.edgeWidth)
                if hovered {
                    Text(String(student.eduid)).frame(minWidth: 50)
                        .background(Rectangle().fill(Color.yellow))
                        .shadow(radius: 5)
                        .offset(x: 40, y: -20)
                        .opacity(0.5)
                }
            }.onHover(perform: { _ in self.hovered.toggle() })
            
            Divider().padding(dividerInsets)
            
            Text((operation.getOutputPath() as NSString).lastPathComponent)
                .frame(width: RenameOperationCell.centerWidth)

            Divider().padding(dividerInsets)
                
            StatusView(status: operation.getStatus())
                .frame(width: RenameOperationCell.edgeWidth)
                
            
        }.frame(width: RenameView.safeWidth, height: 30)
        .background(self.color)
    }
    
    private struct StudentNameView: View {
        let student: Student
        
        var body: some View {
            Text(student.firstName + " " + student.lastName)
        }
    }
    
    private struct StatusView: View {
        var status: CopyOperation.CopyStatus
        let baseFontSize = CGFloat(14)
        
        var body: some View {
            StatusView.statusToText(s: status, fontSize: baseFontSize)
        }
        
        static func statusToText(s: CopyOperation.CopyStatus, fontSize: CGFloat) -> Text {
            var textColor: Color
            var text: String
            
            switch s {
            case .AlreadyExists:
                text = "Already exists"
                textColor = .blue
            case .Copied:
                text = "Renamed"
                textColor = .green
            case .Overwritten:
                text = "Overwrote existing file"
                textColor = .orange
            case .Pending:
                text = "Pending"
                textColor = .black
            case .Unsuccessful:
                text = "Failed"
                textColor = .red
            }
            
            return Text(text)
                .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                .foregroundColor(textColor)
        }
    }
}

struct RenameView_Previews: PreviewProvider {
    
    private static func initCopyManager() -> CopyManager {
        let path = "/Users/Brandon/Library/Mobile Documents/com~apple~CloudDocs/Programming/Projects/Sobriquet/test-files/"
        let outputPath = "/Users/Brandon/Library/Mobile Documents/com~apple~CloudDocs/Programming/Projects/Sobriquet/test-output"
        let outputFormat = "%Last Name%_%First Name%_%Last Name%_test"
        var manager = CopyManager()
        
        let operations = try! CopyManager.loadCopyOperations(inputPath: path, outputPath: outputPath, outputFormat: outputFormat, studentManager: try! StudentManager())
        
        let firstFive = operations[0...5]
        manager.update(operations: Array(firstFive))
        return manager
    }
    
    private static func initStudent() -> Student {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        let allStudents = try! moc.fetch(Student.getAllStudents())
        
        return allStudents[0]
    }
    
    static var previews: some View {
        let manager = initCopyManager()
        
        return RenameView(showView: .constant(true),
                   currentProgress: .constant(1),
                   numFiles: .constant(10), copyManager: .constant(manager))
//        RenameOperationCell(currentIndex: 4,
//                            op: RenameView_Previews.initCopyOperation())
    }
}
