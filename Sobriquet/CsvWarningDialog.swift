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
    @Binding var studentManager: StudentManager
    @Binding var showAlert: Bool
    @Binding var alertType: CSVParser.ParserError
    @Binding var isUniqueError: Bool
    
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
            Button(action: updateStudents) { Text("Choose") }
                .buttonStyle(ExecuteButtonStyle(isDisabled: .constant(false)))
        }.padding(.trailing, 30)
    }
    
    private static func getFont(size: CGFloat) -> Font {
        return .system(size: size, weight: .light, design: .rounded)
    }
    
    public func updateStudents() {
        var path: String?
         
        let fileDialog = CsvWarningDialog.fileDialog()
        
        fileDialog.begin { response in
            if response == .OK {
                path = fileDialog.url?.path
                if path == nil || path!.isEmpty {
                    return
                }
                
                do {
                    defer {
                        if self.showWarningDialog {
                            self.showWarningDialog.toggle()
                        }
                    }
                    
                    let students = try StudentManager.getStudentsFromFile(fileName: path!)
                    try self.studentManager.update(students: students)
                } catch CSVParser.ParserError.FileNotFound {
                    self.alertType = .FileNotFound
                    self.showAlert.toggle()
                } catch CSVParser.ParserError.MalformedCSV {
                    self.alertType = .MalformedCSV
                    self.showAlert.toggle()
                } catch StudentManager.StudentManagerError.NonUniqueElementError {
                    self.alertType = .Unknown
                    self.isUniqueError = true
                    self.showAlert.toggle()
                } catch {
                    self.alertType = .Unknown
                    self.showAlert.toggle()
                }
            } else {
                if self.showWarningDialog {
                    self.showWarningDialog.toggle()
                }
            }
        }
     }
    
    private static func fileDialog() -> NSOpenPanel {
        let fileDialog = NSOpenPanel()

        fileDialog.prompt = "Select path"
        fileDialog.worksWhenModal = true
        fileDialog.canChooseDirectories = false
        fileDialog.canChooseFiles = true
        fileDialog.canCreateDirectories = false
        fileDialog.allowsMultipleSelection = false
        
        return fileDialog
    }
    
    private static func getFileNameFromDialog() -> String? {
        var path: String?
        let fileDialog = CsvWarningDialog.fileDialog()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = fileDialog.runModal()
            if result == .OK {
                path = fileDialog.url!.absoluteString
            }
        }
        
        return path
    }
}

struct CsvWarningDialog_Previews: PreviewProvider {
    static var previews: some View {
        CsvWarningDialog(showWarningDialog: .constant(true),
                         studentManager: .constant(try! StudentManager()),
                         showAlert: .constant(false),
                         alertType: .constant(.Unknown),
                         isUniqueError: .constant(true))
    }
}
