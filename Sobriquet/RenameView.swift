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
    
    var body: some View {
        
        VStack {
            Spacer()
            Header()
            RenameOperations(manager: $copyManager, executed: $executed,
                             selectedFilter: $selectedFilter)
            
            ProgressBar(value: $currentProgress, maxValue: Double(copyManager.count),
                        backgroundColor: colorScheme == .dark ? .darkModeTextViewBackground : .white)
                .frame(width: RenameView.safeWidth)
            
            Spacer()
            Footer(selectedFilter: $selectedFilter, executed: $executed,
                   overwrite: $overwrite, copyManager: $copyManager, showView: $showView,
                   copyProgress: $currentProgress)
            Spacer()
            
        }.frame(width: RenameView.sheetWidth, height: 600)
            .background(colorScheme == .dark ? Color.darkModeBackground : Color.lightModeBackground)
            .border(colorScheme == .dark ? Color.darkModeOutline : Color.outlineColor, width: 1)
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
                        RenameOperationCell(currentIndex: index,
                                            op: self.manager.getOperation(at: index),
                                            colorScheme: self.colorScheme)
                            .listRowInsets(.init())
                            .listRowBackground(RenameOperationCell.getCellColor(index: index, mode: self.colorScheme))
                            .offset(x: -5)
                    }
                }
            }
            .environment(\.defaultMinListRowHeight, RenameOperationCell.cellHeight)
            .id(UUID())  // Forces complete reload; not sure why
            .frame(width: RenameView.safeWidth, height: 470)
            .background(colorScheme == .dark ? Color.darkModeTextViewBackground : Color.white)
            .cornerRadius(RenameView.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: RenameView.cornerRadius)
                    .stroke(colorScheme == .dark ? Color.darkModeOutline : Color.outlineColor, lineWidth: 1)
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
    
    struct Footer: View {
        @Binding var selectedFilter: Int
        @Binding var executed: Bool
        @Binding var overwrite: Bool
        @Binding var copyManager: CopyManager
        @Binding var showView: Bool
        @Binding var copyProgress: Double
        
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
                
            }.frame(width: RenameView.safeWidth)
        }
        
        private func exitView() {
            self.copyProgress = 0
            self.selectedFilter = 0
            if self.executed { self.executed.toggle() }
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
    
    static let cellHeight = CGFloat(40)
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
    
    /// Padding to make the dividers shorter than the height of the view
    private let dividerInsets = EdgeInsets(top: RenameOperationCell.verticalPad, leading: 0,
                                           bottom: RenameOperationCell.verticalPad, trailing: 0)
    
    /// The file representing the relevant student
    private var studentFile: StudentFile { return operation.getStudentFile() }
    
    /// The student represented by the `studentFile` property
    private var student: Student { return studentFile.getStudent() }
    
    /// The operation to be performed
    @ObservedObject private var operation: CopyOperation
    
    /// Whether the cell is hovered over
    @State var hovered: Bool = false
    
    init(currentIndex: Int, op: CopyOperation, colorScheme: ColorScheme) {
        self.operation = op
    }
    
    static func getCellColor(index: Int, mode: ColorScheme) -> Color {
        // even cells should be white, odd light gray
        if index % 2 == 0 {
            return mode == .dark ? .renameViewDarkCell : .white
        } else {
            return mode == .dark ? .darkModeLightGray : .lightGray
        }
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
                
            
        }.frame(height: RenameOperationCell.cellHeight)
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
                    Text(baseName)
                    .fixedSize(horizontal: true, vertical: false)
                        .background(Rectangle().fill(Color.yellow))
                        .shadow(radius: 5)
                        .offset(x: 40, y: -13)
                        .opacity(0.7)
                }
            } .onHover { over in self.hovered = over }
        }
    }
    
    private struct StudentNameView: View {
        @Environment(\.colorScheme) var colorScheme
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
                if hovered && self.status != .StudentUnknown {
                    Text("EDUID: " + String(student.eduid))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(minWidth: 50)
                        .background(Rectangle().fill(Color.yellow))
                        .shadow(radius: 5)
                        .offset(x: 40, y: -13)
                        .opacity(0.7)
                }
            }.onHover(perform: { over in self.hovered = over })
        }
    }
    
    private struct StatusView: View {
        @Environment(\.colorScheme) var colorScheme
        var status: CopyOperation.CopyStatus
        let baseFontSize = CGFloat(14)
        
        var body: some View {
            statusToText(s: status, fontSize: baseFontSize)
        }
        
        func statusToText(s: CopyOperation.CopyStatus, fontSize: CGFloat) -> Text {
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
                textColor = colorScheme == .dark ? .white : .black
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
        
        return RenameView(showView: .constant(true),
                   currentProgress: .constant(1),
                   copyManager: .constant(manager))
//        return RenameOperationCell(currentIndex: 4,
//                                   op: manager.getOperation(at: 4),
//                                   colorScheme: .dark)
    }
}
#endif
