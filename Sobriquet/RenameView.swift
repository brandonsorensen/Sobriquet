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
    @State var allFiles = [StudentFile]()
    @State var executed = false
    @State var overwrite = false
    @Binding var showView: Bool
    @Binding var currentProgress: Double
    @Binding var numFiles: Double
    
    private static let cornerRadius = CGFloat(7)
    private static let buttonWidth = CGFloat(100)
    private static let sheetWidth = CGFloat(600)
    private static let safeWidth = sheetWidth * 0.88
    
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
            RenameOperations(displayText: $displayText)
            
            ProgressBar(value: $currentProgress, maxValue: $numFiles,
                        backgroundColor: colorScheme == .dark ? RenameView.darkModeTextViewBackground : Color.white)
                .frame(width: RenameView.safeWidth)
            
            Spacer()
            Footer(displayText: $displayText, selectedFilter: $selectedFilter, executed: $executed,
                   overwrite: $overwrite, allFiles: $allFiles, showView: $showView)
            Spacer()
            
        }.frame(width: RenameView.sheetWidth, height: 600)
            .background(colorScheme == .dark ? RenameView.darkModeBackground : RenameView.lightModeBackground)
            .border(colorScheme == .dark ? RenameView.darkModeOutline : RenameView.outlineColor, width: 1)
        .clipped()
        .shadow(radius: 3)
        .offset(y: -1)  // Hides top shadow
    }
    
    private struct Header: View {
        private let columns = [
                   "Student", "Output Preview", "Status"
               ]
        
        var body: some View {
            VStack {
                Text("Rename Files").font(.headline)
                Spacer()
                Divider().frame(width: RenameView.safeWidth)
                HStack {
                    ForEach(0..<self.columns.count) { index in
                        Spacer()
                        Text(self.columns[index])
                        Spacer()
                        if index != self.columns.count - 1 {
                            Divider()
                        }
                    }
                }//.foregroundColor(.gray)
                .frame(width: RenameView.safeWidth, height: 15, alignment: .top)
            }.offset(y: 2)

        }
    }
    
    private struct RenameOperations: View {
        @Environment(\.colorScheme) var colorScheme
        @Binding var displayText: String
        
        var body: some View {
            ScrollView(showsIndicators: false) {
                
                if self.displayText.isEmpty {
                    Text("\nRename operations will display here.")
                        .foregroundColor(.gray)
                        .frame(alignment: .center)
                } else {
                    Text("")
                    Text(displayText)
                }
            }
            .frame(width: RenameView.safeWidth, height: 470)
            .background(colorScheme == .dark ? darkModeTextViewBackground : Color.white)
            .cornerRadius(RenameView.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: RenameView.cornerRadius)
                .stroke(colorScheme == .dark ? darkModeOutline : outlineColor, lineWidth: 1)
            )
        }
    }
    
    private struct Footer: View {
        @Binding var displayText: String
        @Binding var selectedFilter: Int
        @Binding var executed: Bool
        @Binding var overwrite: Bool
        @Binding var allFiles: [StudentFile]
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
                    self.displayText = "HELLO!"
                    self.allFiles.removeAll()
                    }) { Text("Execute") }
                .buttonStyle(ExecuteButtonStyle())
                
            }.padding(.bottom, 10)
                .frame(width: RenameView.safeWidth)
        }
    }
}

struct RenameOperationCell: View {
    
    private let color: Color
    private let studentFile: StudentFile
    
    init(currentIndex: Int, studentFile: StudentFile) {
        self.color = currentIndex % 2 == 0 ? Color.white : Color.gray
        self.studentFile = studentFile
    }
    
    var body: some View {
        HStack {
            Text(studentFile.getStudent().lastName)
        }
    }
}

struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
        RenameView(showView: .constant(true), currentProgress: .constant(10), numFiles: .constant(100))
//        RenameOperationCell(currentIndex: 4)
    }
}
