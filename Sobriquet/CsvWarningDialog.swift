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
    @State var showAlert: Bool = false
    @State var alertType: CSVParser.ParserError = .Unknown
    @State var isUniqueError: Bool = false
    
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
            .alert(isPresented: $showAlert) { return alertSwitch(activeAlert: alertType) }
    }
    
    func alertSwitch(activeAlert: CSVParser.ParserError) -> Alert {
        let dismissButton: Alert.Button = .default(Text("OK"))
        var title: Text
        var message: Text
        
        switch activeAlert {
        case .FileNotFound:
            title = Text("File Not Found")
            message = Text("Could not find file.")
        case .MalformedCSV:
            title = Text("Malformed CSV")
            message = Text("Ensure the CSV file has the right encoding and format: Last Name, First Name, Middle Name, EDUID")
            
        case .Unknown:
            if isUniqueError {
                isUniqueError = false
                title = Text("Non-unique students")
                message = Text("Two or more students have the same EDUID.")
            } else {
                return Alert(title: Text("Unknown error."))
            }
        }
        
        return Alert(title: title, message: message, dismissButton: dismissButton)
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
                if !self.showAlert {
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

#if DEBUG
struct CsvWarningDialog_Previews: PreviewProvider {
    static var previews: some View {
        CsvWarningDialog(showWarningDialog: .constant(true),
                         studentManager: .constant(try! StudentManager()),
                         isUniqueError: true)
    }
}
#endif
