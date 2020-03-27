//
//  CsvWarningDialog.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/27/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

struct CsvWarningDialog: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showWarningDialog: Bool
    
    private static let sheetWidth = CGFloat(500)
    private static let sheetHeight = sheetWidth * 0.8
    private static let imageSheetRatio = CGFloat(0.88)
    
    private static let imageWidth = sheetWidth * imageSheetRatio
    private static let imageHeight = imageWidth * (9 / 16)
    
    private static let smallTextSize = CGFloat(10)
    
    var body: some View {
        let backgroundColor: Color = colorScheme == .light ? .lightModeBackground : .darkModeBackground
        let sheetOutlineColor: Color = colorScheme == .light ? .outlineColor : .darkModeOutline
        
        return VStack {
            Spacer()
            CsvWarningDialog.getHeaderText()
            Spacer()
            
            getExampleImage()
            
            Spacer()
            getFooterButtons()
            Spacer()
        }.frame(width: CsvWarningDialog.sheetWidth,
                height: CsvWarningDialog.sheetHeight)
        .background(backgroundColor)
            .border(sheetOutlineColor, width: 1)
    }
    
    private static func getHeaderText() -> some View {
        return VStack {
            Text("Notice")
                .font(CsvWarningDialog.getFont(size: 25).lowercaseSmallCaps())
            Text("Ensure the CSV file is in the following format")
                .font(CsvWarningDialog.getFont(size: 14))
            HStack {
                Text("Header is optional")
                    .font(CsvWarningDialog.getFont(size: CsvWarningDialog.smallTextSize))
                Divider()
                Text("Columns must be in the order show below")
                    .font(CsvWarningDialog.getFont(size: CsvWarningDialog.smallTextSize))
                Divider()
                Text("No Excel files")
                    .font(CsvWarningDialog.getFont(size: CsvWarningDialog.smallTextSize))
            }.frame(height: 10)
        }
    }
    
    private func getExampleImage() -> some View {
        let imageOutlineColor: Color = colorScheme == .light ? .black : .white
        return Image("csv-example")
            .resizable()
            .border(imageOutlineColor, width: 1)
            .frame(width: CsvWarningDialog.imageWidth,
                   height: CsvWarningDialog.imageHeight)
            .shadow(radius: 10)
    }
    
    private func getFooterButtons() -> some View {
        return HStack {
            Spacer()
            Button(action: { self.showWarningDialog.toggle() }) { Text("  Cancel  ") }
            Button(action: {}) { Text("Choose") }
                .buttonStyle(ExecuteButtonStyle(isDisabled: .constant(false)))
        }.padding(.trailing, 30)
    }
    
    private static func getFont(size: CGFloat) -> Font {
        return .system(size: size, weight: .light, design: .rounded)
    }
}

struct CsvWarningDialog_Previews: PreviewProvider {
    static var previews: some View {
        CsvWarningDialog(showWarningDialog: .constant(true))
    }
}
