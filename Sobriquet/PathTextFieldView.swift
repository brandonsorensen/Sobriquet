//
//  PathTextFieldView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

struct PathTextFieldView: View {
    
    public struct PathTextFieldStyle : TextFieldStyle {
        public func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .font(.largeTitle) // set the inner Text Field Font
                .padding(10) // Set the inner Text Field Padding
                //Give it some style
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(Color.primary.opacity(0.5), lineWidth: 3))
        }
    }
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PathTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        PathTextFieldView()
    }
}
