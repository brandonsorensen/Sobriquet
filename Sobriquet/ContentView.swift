//
//  ContentView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI
import AppKit

struct ContentView: View {
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
            TextField("Enter path to files.", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top, 30)
                .frame(width: 800)
            
            ComponentButtonsUIView().frame(width: 800)
            
            OutputFileView()
                .frame(width: 800)
                .padding(.leading, 30)
                .padding(.trailing, 30)
            
            Button(action: {}) {
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
