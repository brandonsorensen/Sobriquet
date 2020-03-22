//
//  RenameView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/21/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

struct RenameView: View {
    @Binding var showView: Bool
    @Binding var currentProgress: Double
    @Binding var numFiles: Double
    
    var body: some View {
        ZStack {
//            .frame(width: 550, height: 550)
            VStack {
                Spacer()
                HStack {
                    Button(action: { self.showView.toggle() }) { Text("Cancel") }
                    Button(action: {}) { Text("OK") }
                }
                Spacer()
                ProgressBar(value: $currentProgress, maxValue: $numFiles).padding(EdgeInsets(top: 0, leading: 30, bottom: 30, trailing: 30))
            }.frame(width: 600, height: 500)
            .background(Color.white)
            .shadow(radius: 3)
        }
    }
}

struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
        RenameView(showView: .constant(true), currentProgress: .constant(50), numFiles: .constant(100))
    }
}
