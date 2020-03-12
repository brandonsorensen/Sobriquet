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
    @State var outputPath: String = ""
    @State var outputFormat: String = ""
    
    var body: some View {
        VStack {
            HStack {
                    Text("Output Format:").font(.subheadline)
                        .padding(.leading, 10)
                        .padding(.bottom, padSize)
                TextField("Enter output format.", text: $outputFormat)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, padSize)
                }
        
            HStack {
                Text("Output Path:").font(.subheadline)
                    .padding(.leading, 10)
                    .padding(.trailing, 18)
                    .padding(.bottom, padSize)

                TextField("Enter path to files.", text: $outputPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, padSize)
                
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
                    }.offset(y: -8)
            }
        }
    }
}

struct OutputFileView_Previews: PreviewProvider {
    static var previews: some View {
        OutputFileView()
    }
}

private func createFileDialog() -> NSOpenPanel {
    let fileDialog = NSOpenPanel()

    fileDialog.prompt = "Select path"
    fileDialog.worksWhenModal = true
    fileDialog.canChooseDirectories = true
    fileDialog.canChooseFiles = false
    fileDialog.canCreateDirectories = true
    fileDialog.allowsMultipleSelection = false
    
    return fileDialog
}

