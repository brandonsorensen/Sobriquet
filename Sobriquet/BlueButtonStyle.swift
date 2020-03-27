//
//  BlueButtonStyle.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/27/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

struct ExecuteButtonStyle: ButtonStyle {
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
