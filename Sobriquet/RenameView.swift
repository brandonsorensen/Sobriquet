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
    @Binding var showView: Bool
    @Binding var currentProgress: Double
    @Binding var numFiles: Double
    
    private let filters = [
        "-- Select Filter --",
        "Successfully copied",
        "File Not Found",
        "File already exists",
        "File overwritten"
    ]
    
    private let cornerRadius = CGFloat(7)
    private let buttonWidth = CGFloat(100)
    private let sheetWidth = CGFloat(600)
    
    private let lightModeBackground = Color(
        red: 235 / 255,
        green: 235 / 255,
        blue: 235 / 255
    )
    
    private let darkModeBackground = Color(
        red: 53 / 255,
        green: 54 / 255,
        blue: 55 / 255
    )
    
    private let darkModeTextViewBackground = Color(
        red: 64 / 255,
        green: 65 / 255,
        blue: 67 / 255
    )
    
    private let darkModeOutline = Color(
        red: 77 / 255,
        green: 78 / 255,
        blue: 80 / 255
    )
    
    private let outlineColor = Color(
        red: 206 / 255,
        green: 206 / 255,
        blue: 206 / 255
    )
    
    struct ExecuteButtonStyle: ButtonStyle {
        @State private var isPressed = false
        
        static let cornerRadius = CGFloat(4.0)
        
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(width: 70, height: 20)
                .foregroundColor(configuration.isPressed ? Color.blue : Color.white)
                .background(configuration.isPressed ? Color.white : Color.blue)
                .cornerRadius(ExecuteButtonStyle.cornerRadius)
                .disableAutocorrection(true)
        }
    }
    
    var body: some View {
        let safeWidth = sheetWidth * 0.88
        
        return VStack {
            Spacer()
            Text("Renaming Files").font(.headline)
            Spacer()
            
            ScrollView(displayText.isEmpty ? [] : .vertical, showsIndicators: false) {
                if self.displayText.isEmpty {
                    Text("\nRename operations will display here.")
                        .foregroundColor(.gray)
                } else {
                    Text("")
                    Text(displayText)
                }
            }
            .frame(width: safeWidth, height: 470)
            .background(colorScheme == .dark ? darkModeTextViewBackground : Color.white)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(colorScheme == .dark ? darkModeOutline : outlineColor, lineWidth: 1)
            )
            
            ProgressBar(value: $currentProgress, maxValue: $numFiles,
                        backgroundColor: colorScheme == .dark ? darkModeTextViewBackground : Color.white)
                .frame(width: safeWidth)
            
            Spacer()
    
            HStack {
                Picker(selection: $selectedFilter, label:
                Text("")) {
                    ForEach(0..<filters.count, id: \.self) {
                        Text(self.filters[$0])
                    }
                }.frame(width: 200, alignment: .leading)
                    .offset(x: -9)  // Make up for empty label
                    .disabled(!executed)
                
                Spacer()
                Button(action: { self.displayText = ""; self.showView.toggle() }) { Text("Cancel") }.frame(alignment: .center)
                Button(action: {
                    self.displayText = "HELLO!"
                    self.allFiles.removeAll()
                    }) { Text("Execute") }
                .buttonStyle(ExecuteButtonStyle())
                
            }.padding(.bottom, 10)
            .frame(width: safeWidth)
            
            Spacer()
            
        }.frame(width: sheetWidth, height: 580)
        .background(colorScheme == .dark ? darkModeBackground : lightModeBackground)
            .border(colorScheme == .dark ? darkModeOutline : outlineColor, width: 1)
        .clipped()
        .shadow(radius: 3)
        .offset(y: -1)  // Hides top shadow
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
