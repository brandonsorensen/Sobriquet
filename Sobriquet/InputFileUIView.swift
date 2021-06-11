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
    @Binding var enrollmentViewState: Bool
    @Binding var eduidLocation: Int
    @Binding var inputPath: String
    
    var body: some View {
        VStack {
            TopLineView(selectedLocation: $eduidLocation, enrollmentViewState: $enrollmentViewState)
            InputPathBar(inputPath: $inputPath)
        }
    }
}

struct InputPathBar: View {
    @Binding var inputPath: String
    
    var body: some View {
        HStack {
            Text("Input Path:")
            .padding(.trailing, 34)

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

struct TopLineView: View {
    @Binding var selectedLocation: Int
    @Binding var enrollmentViewState: Bool
    
    var body: some View {
        HStack {
            Picker(selection: $selectedLocation, label: Text("EDUID Location:")
                .padding(.trailing, 3)) {
            Text("-- Select Location --").tag(0)
            Text("File Name").tag(1)
            Text("File Contents").tag(2)
                }.frame(maxWidth: 300)
            
            Spacer()
            
            Text("Enrollment").offset(x: 6)
            Button(action: { self.enrollmentViewState.toggle() }) {
                HStack {
                    Image("enrollment_icon")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 25, height: 25, alignment: .trailing)
                        .offset(x: 4)
                    
                    Image(systemName: enrollmentViewState ? "chevron.left" : "chevron.right")
                        .font(.system(size: 22))
                }
            }.buttonStyle(PlainButtonStyle())
        }
    }
    
    var arrowIcon: String { enrollmentViewState ? "left-arrow-icon" : "right-arrow-icon" }
}

struct InputFileUIView_Previews: PreviewProvider {
    static var previews: some View {
        InputFileUIView(enrollmentViewState: .constant(false), eduidLocation: .constant(0),
                        inputPath: .constant(""))
    }
}
