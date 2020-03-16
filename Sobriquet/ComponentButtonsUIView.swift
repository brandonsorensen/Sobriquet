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

enum ComponentButtonType: String, CaseIterable {
    case LAST_NAME = "%Last Name%";
    case FIRST_NAME = "%First Name%";
    case EDUID = "%EDUID%";
    case MIDDLE_NAME = "%Middle Name%";
    case MIDDLE_INITIAL = "%Middle Initial%";
}

struct ComponentButtonsUIView: View {
    
    var body: some View {
         
        HStack {
            ForEach(ComponentButtonType.allCases, id: \.self) { button in
                ComponentButton(type: button)
            }
        }
    }
}

struct ComponentButton: View {
    @State private var hovered = false
    var type: ComponentButtonType
    
    struct ComponentButtonStyle: ViewModifier {
        @Binding var hovered: Bool
        
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
            .padding(.top, 50)
            .padding(.bottom, 50)
        }
    }
    
    var body: some View {
        var buttonString = self.type.rawValue
        buttonString.removeLast()
        buttonString.removeFirst()
        
        return Button(action: {}) {
            Text(buttonString)
            .textStyle(ComponentButtonStyle(hovered: $hovered))
            .onDrag { return NSItemProvider(object: self.type.rawValue as NSString) }
        }.buttonStyle(PlainButtonStyle())
         .onHover { _ in self.hovered.toggle() }
    }
}

struct ComponentButtonDropDelegate: DropDelegate {
    @Binding var outputFormat: String
    
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: ["NSString"]).first {
            item.loadItem(forTypeIdentifier: "NSString", options: nil) { (componentString, error) in
                self.outputFormat.append(componentString as! String)
            }
            return true
        }
        return false
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: ["NSString"])
    }
}

struct ComponentButtonsUIView_Previews: PreviewProvider {
    static var previews: some View {
        ComponentButtonsUIView()
    }
}
