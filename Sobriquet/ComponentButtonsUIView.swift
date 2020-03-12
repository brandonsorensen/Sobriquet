//
//  ComponentButtonsUIView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

extension Text {
    func textStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}

extension String: Identifiable {
    public var id: String {
        return self
    }
}

struct ComponentButtonsUIView: View {
    
    struct ComponentButtonStyle: ViewModifier {
        @State private var hovered = false
        
        let unselectColor = Color(red: 76 / 255, green: 83 / 255, blue: 94 / 255)
        let selectedColor = Color(red: 119 / 255, green: 123 / 255, blue: 128 / 255)
        
        func body(content: Content) -> some View {
            content
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .frame(idealWidth: 120, idealHeight: 40)
                    .fixedSize()
                    .foregroundColor(self.hovered ? selectedColor : unselectColor)
            )
                .onHover { _ in self.hovered.toggle() }
            .padding(.top, 50)
            .padding(.bottom, 50)
        }
    }
    
    let labels = [
        "Last Name", "First Name", "Middle Name",
        "Middle Initial", "EDUID", "Wildcard (*)"
    ]
    
    var body: some View {
         
        HStack {
            ForEach(0 ..< labels.count) { index in
            Text(self.labels[index]).textStyle(ComponentButtonStyle())
            }
        }
    }
}

struct ComponentButtonsUIView_Previews: PreviewProvider {
    static var previews: some View {
        ComponentButtonsUIView()
    }
}
