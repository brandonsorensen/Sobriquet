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
        func body(content: Content) -> some View {
            content
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .frame(idealWidth: 120, idealHeight: 40)
                    .fixedSize()
            )
            .padding()
        }
    }
    
    let labels = [
        "Last Name", "First Name", "Middle Name",
        "Middle Initial", "EDUID", "Wildcard (*)"
    ]
    
    var body: some View {
         
        HStack {
            Spacer()
            ForEach(0 ..< labels.count) { index in
                Text(self.labels[index]).textStyle(ComponentButtonStyle())
                Spacer()
            }
        }
    }
}

struct ComponentButtonsUIView_Previews: PreviewProvider {
    static var previews: some View {
        ComponentButtonsUIView()
    }
}
