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
        let dropDelegate = ComponentButtonDropDelegate(outputFormat: $outputFormat)
        
        return VStack {
            HStack {
                    Text("Output Format:").font(.subheadline)
                        .padding(.bottom, padSize)
                TextField("Enter output format.", text: $outputFormat)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, padSize)
                        .onDrop(of: ["String"], delegate: dropDelegate)
                }
        
            HStack {
                Text("Output Path:").font(.subheadline)
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
