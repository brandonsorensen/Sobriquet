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
    @Binding var showView: Bool
    @Binding var currentProgress: Double
    @Binding var numFiles: Double
    
    let cornerRadius = CGFloat(7)
    let buttonWidth = CGFloat(100)
    
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
        VStack {
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
            .frame(width: 530, height: 450)
            .background(Color.white)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(outlineColor, lineWidth: 1)
            )
            
            ProgressBar(value: $currentProgress, maxValue: $numFiles).padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            
            Spacer()
    
            HStack {
                Button(action: { self.displayText = ""; self.showView.toggle() }) { Text("Cancel") }
                Button(action: { self.displayText = "HELLO!" }) { Text("   OK   ") }
            }
            Spacer()
            
        }.frame(width: 600, height: 550)
        .background(colorScheme == .dark ? darkModeBackground : lightModeBackground)
        .border(outlineColor, width: 1)
        .clipped()
        .shadow(radius: 2)
        .offset(y: -1)
    }
}

struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
        RenameView(showView: .constant(true), currentProgress: .constant(50), numFiles: .constant(100))
    }
}
