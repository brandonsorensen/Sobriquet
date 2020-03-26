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
    @State var selectedFilter = 0
    @State var executed = false
    @State var overwrite = false
    @Binding var showView: Bool
    @Binding var currentProgress: Double
    @Binding var copyManager: CopyManager
    
    private static let cornerRadius = CGFloat(7)
    private static let buttonWidth = CGFloat(100)
    
    static let sheetWidth = CGFloat(800)
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
            RenameOperations(manager: $copyManager, executed: $executed,
                             selectedFilter: $selectedFilter)
            
            ProgressBar(value: $currentProgress, maxValue: Double(copyManager.count),
                        backgroundColor: colorScheme == .dark ? RenameView.darkModeTextViewBackground : Color.white)
                .frame(width: RenameView.safeWidth)
            
            Spacer()
            Footer(selectedFilter: $selectedFilter, executed: $executed,
                   overwrite: $overwrite, copyManager: $copyManager, showView: $showView,
                   copyProgress: $currentProgress)
            Spacer()
            
        }.frame(width: RenameView.sheetWidth, height: 600)
            .background(colorScheme == .dark ? RenameView.darkModeBackground : RenameView.lightModeBackground)
            .border(colorScheme == .dark ? RenameView.darkModeOutline : RenameView.outlineColor, width: 1)
            .clipped()
            .shadow(radius: 3)
            .offset(y: -1)  // Hides top shadow
    }
    
    struct Header: View {
        static let columns = [
                   "File Name", "Student", "Output Preview", "Status"
               ]
        
        /// The magnitude of the spacing – smaller means wider
        static let spacingQuotient = CGFloat(5.3)
        /// How much smaller the other three labels will be compare to "Output Preview"
        static let sizeRatio = CGFloat(0.7)
        
        var body: some View {
            VStack {
                Text("Rename Files").font(.headline)
                Spacer()
                Divider().frame(width: RenameView.safeWidth)
                HStack {
                    ForEach(0..<Header.columns.count) { index in
                        Text(Header.columns[index]).frame(width: RenameView.safeWidth / Header.getQuotientForIndex(index: index))
                        if index != Header.columns.count - 1 {
                            Divider()
                        }
                    }
                }
                .frame(width: RenameView.safeWidth, height: 15, alignment: .top)
            }.offset(y: 2)
        }
        
        static func getQuotientForIndex(index: Int) -> CGFloat {
            return CGFloat(index % 2 != 0 ? Header.spacingQuotient : Header.spacingQuotient * Header.sizeRatio)
        }
    }
    
    private struct RenameOperations: View {
        @Environment(\.colorScheme) var colorScheme
        @Binding var manager: CopyManager
        @Binding var executed: Bool
        @Binding var selectedFilter: Int
        var filteredIndices: [Int] {
            let filter = intToCopyStatus(i: selectedFilter)
            let filterByExclude = !executed && filter == .Copied
            return manager.filter(by: filter, exclude: filterByExclude)
        }
        
        var body: some View {
            List {
                if self.filteredIndices.isEmpty {
                    HStack{
                        Spacer()
                        Text("\nRename operations will display here.")
                            .foregroundColor(.gray)
                            .frame(alignment: .center)
                        Spacer()
                    }
                } else {
                    ForEach(self.filteredIndices, id: \.self) { index in
                        RenameOperationCell(currentIndex: index, op: self.manager.getOperation(at: index))
                    }
                }
            }
            .id(UUID())  // Forces complete reload; not sure why
            .padding(.horizontal, -9)
            .frame(width: RenameView.safeWidth, height: 470)
            .background(colorScheme == .dark ? RenameView.darkModeTextViewBackground : Color.white)
            .cornerRadius(RenameView.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: RenameView.cornerRadius)
                    .stroke(colorScheme == .dark ? RenameView.darkModeOutline : RenameView.outlineColor, lineWidth: 1)
            )
        }
        
        private func intToCopyStatus(i: Int) -> CopyOperation.CopyStatus? {
            if executed {
                switch i {
                case 1:
                    return .Copied
                case 2:
                    return .AlreadyExists
                case 3:
                    return .Overwritten
                case 4:
                    return .Unsuccessful
                case 5:
                    return .StudentUnknown
                default:
                    return nil
                }
            } else {
                switch i {
                case 2:
                    return .StudentUnknown
                default:
                    return .Copied
                }
            }
        }
    }
    
    private struct Footer: View {
        @Binding var selectedFilter: Int
        @Binding var executed: Bool
        @Binding var overwrite: Bool
        @Binding var copyManager: CopyManager
        @Binding var showView: Bool
        @Binding var copyProgress: Double
        
        private struct ExecuteButtonStyle: ButtonStyle {
            @State private var isPressed = false
            @Binding var isDisabled: Bool
            
            static let cornerRadius = CGFloat(4.0)
            
            func makeBody(configuration: Self.Configuration) -> some View {
                configuration.label
                    .frame(width: 70, height: 20)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .overlay(Color.black.opacity(configuration.isPressed ? 0.15 : 0))
                    .overlay(Color.gray.opacity(isDisabled ? 0.4 : 0))
                    .cornerRadius(ExecuteButtonStyle.cornerRadius)
                    .disableAutocorrection(true)
                    .animation(.none)
                    
            }
        }
        
        private let filters = [
            "-- Select Filter --",
            "Successfully copied",
            "File already exists",
            "File overwritten",
            "Failure",
            "Non student files"
        ]
        
        private let preExecutionFilters = [
            "-- Select Filter --",
            "Student Files",
            "Non student files"
        ]
        
        var body: some View {
            HStack {
                if executed {
                    Picker(selection: $selectedFilter, label:
                    Text("")) {
                        ForEach(0..<filters.count, id: \.self) {
                            Text(self.filters[$0])
                        }
                    }.frame(width: 200, alignment: .leading)
                        .offset(x: -9)  // Make up for empty label
                } else {
                    Picker(selection: $selectedFilter, label:
                    Text("")) {
                        ForEach(0..<self.preExecutionFilters.count, id: \.self) {
                            Text(self.preExecutionFilters[$0])
                        }
                    }.frame(width: 200, alignment: .leading)
                        .offset(x: -9)  // Make up for empty label
                }
                
                Toggle(isOn: $overwrite) {
                    Text("Overwrite existing files")
                }
                
                Spacer()
                Button(action: exitView) { Text("Cancel") }.frame(alignment: .center)
                Button(action: executeCopy) { Text("Execute") }
                .buttonStyle(ExecuteButtonStyle(isDisabled: $executed))
                .disabled(executed)
                
            }.padding(.bottom, 10)
                .frame(width: RenameView.safeWidth)
        }
        
        private func exitView() {
            self.copyProgress = 0
            self.selectedFilter = 0
            self.executed.toggle()
            self.showView.toggle()
        }
        
        func executeCopy() {
            for index in 0..<copyManager.count {
                let _ = copyManager.getOperation(at: index).execute(overwrite: overwrite)
                self.copyProgress += 1
            }
            self.selectedFilter = 0
            self.executed.toggle()
        }
    }
}

struct RenameOperationCell: View {
    
    /// Leading and trailing padding
    private static let edgePadding = CGFloat(10)
    
    /// Padding between each cell
    private static let verticalPad = CGFloat(5)
    
    /// The number of columns in the view
    private static let nViews = CGFloat(RenameView.Header.columns.count)
    
    /// The width of the longer cells: "File Name" & "Output Preview"
    private static var centerWidth: CGFloat {
        RenameView.safeWidth /  RenameView.Header.getQuotientForIndex(index: 2)
    }
    
    /// The width of the shorter cells: "Student" & "Status"
    private static var edgeWidth: CGFloat {
        RenameView.safeWidth / RenameView.Header.getQuotientForIndex(index: 1)
    }
    
    static let lightGray = Color(red: 249 / 255, green: 250 / 255, blue: 250 / 255)
    
    /// Padding to make the dividers shorter than the height of the view
    private let dividerInsets = EdgeInsets(top: RenameOperationCell.verticalPad, leading: 0,
                                           bottom: RenameOperationCell.verticalPad, trailing: 0)
    
    /// The current color of the cells
    private let color: Color
    
    /// The file representing the relevant student
    private var studentFile: StudentFile { return operation.getStudentFile() }
    
    /// The student represented by the `studentFile` property
    private var student: Student { return studentFile.getStudent() }
    
    /// The operation to be performed
    @ObservedObject private var operation: CopyOperation
    
    /// Whether the cell is hovered over
    @State var hovered: Bool = false
    
    init(currentIndex: Int, op: CopyOperation) {
        self.color = currentIndex % 2 == 0 ? Color.white : RenameOperationCell.lightGray
        self.operation = op
    }
    
    var body: some View {
        
        HStack {
            FileNameView(path: studentFile.getPath())
                .frame(width: RenameOperationCell.centerWidth)
            
            Divider().padding(dividerInsets)
            
            StudentNameView(student: student, status: operation.getStatus())
                .frame(width: RenameOperationCell.edgeWidth)
            
            Divider().padding(dividerInsets)
            
            if operation.getStatus() != .StudentUnknown {
                FileNameView(path: operation.getOutputPath())
                    .frame(width: RenameOperationCell.centerWidth)
            } else {
                Text("N/A").frame(width: RenameOperationCell.centerWidth)
            }

            Divider().padding(dividerInsets)
                
            StatusView(status: operation.getStatus())
                .frame(width: RenameOperationCell.edgeWidth)
                
            
        }.frame(width: RenameView.safeWidth, height: 30)
        .background(self.color)
    }
    
    private struct FileNameView: View {
        let path: String
        var baseName: String { return (path as NSString).lastPathComponent }
        @State var hovered: Bool = false
        
        var body: some View {
            ZStack {
                Text(baseName)
                    .fixedSize(horizontal: false, vertical: false)
                    .frame(maxWidth: RenameOperationCell.centerWidth)
                if hovered && !path.isEmpty {
                    Text(baseName).frame(minWidth: 100)
                    .fixedSize(horizontal: true, vertical: false)
                        .background(Rectangle().fill(Color.yellow))
                        .shadow(radius: 5)
                        .offset(x: 40, y: -13)
                        .opacity(0.5)
                }
            } .onHover { over in self.hovered = over }
        }
    }
    
    private struct StudentNameView: View {
        let student: Student
        let status: CopyOperation.CopyStatus
        @State var hovered: Bool = false
        
        var body: some View {
            ZStack {
                if self.status == .StudentUnknown {
                    Text("No student found")
                } else {
                    Text(student.firstName + " " + student.lastName)
                }
                if hovered {
                    Text("EDUID: " + String(student.eduid))
                        .frame(minWidth: 50)
                        .background(Rectangle().fill(Color.yellow))
                        .shadow(radius: 5)
                        .offset(x: 40, y: -13)
                        .opacity(0.5)
                }
            }.onHover(perform: { over in self.hovered = over })
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
                text = "Copied"
                textColor = .green
            case .Overwritten:
                text = "Overwritten"
                textColor = .orange
            case .Pending:
                text = "Pending"
                textColor = .black
            case .StudentUnknown:
                text = "No student"
                textColor = .gray
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

#if DEBUG
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
        
//        return RenameView(showView: .constant(true),
//                   currentProgress: .constant(1),
//                   copyManager: .constant(manager))
        return RenameOperationCell(currentIndex: 4,
                                   op: manager.getOperation(at: 4))
    }
}
#endif
