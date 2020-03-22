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
    
    let cornerRadius = CGFloat(7)
    let buttonWidth = CGFloat(100)
    let sheetWidth = CGFloat(600)
    
    let lightModeBackground = Color(
        red: 235 / 255,
        green: 235 / 255,
        blue: 235 / 255
    )
    
    let darkModeBackground = Color(
        red: 53 / 255,
        green: 54 / 255,
        blue: 55 / 255
    )
    
    let outlineColor = Color(
        red: 206 / 255,
        green: 206 / 255,
        blue: 206 / 255
    )
    
    var body: some View {
        let safeWidth = sheetWidth * 0.88
        
        return VStack {
            Spacer()
            Text("Renaming Files").font(.headline)
            Spacer()
            
            ScrollView(displayText.isEmpty ? .vertical : [], showsIndicators: true) {
                if self.displayText.isEmpty {
                    Text("\nRename operations will display here.")
                        .foregroundColor(.gray)
                } else {
                    Text("")
                    Text(displayText)
                }
            }
            .frame(width: safeWidth, height: 470)
            .background(Color.white)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(outlineColor, lineWidth: 1)
            )
            
            ProgressBar(value: $currentProgress, maxValue: $numFiles)
                .frame(width: safeWidth)
            
            Spacer()
    
            HStack {
                Picker(selection: $selectedFilter, label:
                Text("")) {
                    ForEach(0..<filters.count) {
                        Text(self.filters[$0])
                    }
                }.frame(width: 200, alignment: .leading)
                    .offset(x: -9)  // Make up for empty label
                
                Spacer()
                Button(action: { self.displayText = ""; self.showView.toggle() }) { Text("Cancel") }.frame(alignment: .center)
                Button(action: { self.displayText = "HELLO!" }) { Text("   OK   ") }
                .frame(alignment: .center)
                
            }.padding(.bottom, 10)
            .frame(width: safeWidth)
            
            Spacer()
            
        }.frame(width: sheetWidth, height: 580)
        .background(colorScheme == .dark ? darkModeBackground : lightModeBackground)
        .border(outlineColor, width: 1)
        .clipped()
        .shadow(radius: 2)
        .offset(y: -1)  // Hides top shadow
    }
}

struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
        RenameView(showView: .constant(true), currentProgress: .constant(10), numFiles: .constant(100))
    }
}
