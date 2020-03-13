//
//  InputFileUIView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/12/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

struct InputFileUIView: View {
    
    @State private var selectedLocation = 0
    @State private var inputPath: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker(selection: $selectedLocation, label: Text("EDUID Location:")
                .padding(.trailing, 3)) {
            Text("-- Select Location --").tag(0)
            Text("File Name").tag(1)
            Text("File Contents").tag(2)
                }.frame(maxWidth: 300)
            
            HStack {
                Text("Input Path:").font(.subheadline)
                .padding(.trailing, 27)

                TextField("Enter path to files.", text: $inputPath).textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    let fileDialog = createFileDialog()
                    fileDialog.begin { response in
                        if response == .OK {
                            let selectedPath = fileDialog.url!.path
                            if !selectedPath.isEmpty {
                                self.inputPath = selectedPath
                            }
                        }
                        fileDialog.close()
                    }
                }) {
                    Text("Browse").frame(minWidth: 100)
                }
            }
        }
    }
}

struct InputFileUIView_Previews: PreviewProvider {
    static var previews: some View {
        InputFileUIView()
    }
}
