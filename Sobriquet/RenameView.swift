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
    
    var body: some View {
        ZStack {
//            .frame(width: 550, height: 550)
            VStack {
                HStack {
                    Button(action: { self.showView.toggle() }) { Text("Cancel") }
                    Button(action: {}) { Text("OK") }
                }
                Spacer()
            }.frame(width: 500, height: 500)
            .background(Color.white)
        }
    }
}

struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
        RenameView(showView: .constant(true))
    }
}
