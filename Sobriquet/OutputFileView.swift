//
//  OutputFileView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI


struct OutputFileView: View {
    let padSize = CGFloat(15)
    @Binding var outputPath: String
    @Binding var outputFormat: String
    @Binding var extensionText: String
    
    var body: some View {
        let dropDelegate = ComponentButtonDropDelegate(outputFormat: $outputFormat)
        
        return VStack {
            HStack {
                Text("Output Format:").font(.subheadline)
                TextField("Enter output format.", text: $outputFormat)
                    .focusable(false)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onDrop(of: ["String"], delegate: dropDelegate)
                Text("Ext:")
                TextField("Extension", text: $extensionText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 92)
                }
        
            HStack {
                Text("Output Path:").font(.subheadline)
                    .padding(.trailing, 18)

                TextField("Enter path to files.", text: $outputPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    let fileDialog = createFileDialog()
          
                    fileDialog.begin { response in
                        if response == .OK {
                            let selectedPath = fileDialog.url!.path
                            if !selectedPath.isEmpty {
                                self.outputPath = selectedPath
                            }
                        }
                        fileDialog.close()
                    }
                }) {
                    Text("Browse").frame(minWidth: 100)
                    }
            }.padding(.bottom, padSize)
        }
    }
}

struct OutputFileView_Previews: PreviewProvider {
    static var previews: some View {
        OutputFileView(outputPath: .constant("place/to/go"),
                       outputFormat: .constant("%Last Name%_%First Name%"),
                       extensionText: .constant(".pdf"))
    }
}
