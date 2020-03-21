//
//  RenameView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/21/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

struct RenameView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
            HStack {
                Button(action: {}) { Text("Cancel") }
                Button(action: {}) { Text("OK") }
            }
        }.frame(minWidth: 500, minHeight: 500)
            .background(Color.white)
        .padding(10)
    }
}

struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
        RenameView()
    }
}
