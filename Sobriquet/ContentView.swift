//
//  ContentView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    struct PathTextFieldStyle : TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(10)
                .font(.title)
                .cornerRadius(0.25)
        }
    }
    
    var body: some View {
        
        VStack {
            TextField("Enter path to files.", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(20)
            
            ComponentButtonsUIView().frame(width: 800)
            
            TextField("Enter file pattern here.", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(20)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
