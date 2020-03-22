//
//  SliderView.swift
//  Sobriquet
//
//  Created by Brandon Sorensen on 3/22/20.
//  Copyright © 2020 Brandon Sorensen. All rights reserved.
//

import SwiftUI

struct SliderView: View {
    @State private var sliderValue: Double = 0
    private let maxValue: Double = 10
    
    var body: some View {
        VStack {
            Text("Progress bar/indicator will go here")
            
            Spacer()
            
            Slider(value: $sliderValue,
                   in: 0...maxValue)
                .padding(30)
        }
    }
}

struct ProgressConfig {
    static func backgroundColor() -> Color {
        return Color(red: 245/255,
                     green: 245/255,
                     blue: 245/255)
    }
    
    static func foregroundColor() -> Color {
        return Color.black
    }
}

struct ProgressBar: View {
    // https://programmingwithswift.com/swiftui-progress-bar-indicator/
    @Binding var value: Double
    @Binding var maxValue: Double
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color
    
    init(value: Binding<Double>,
         maxValue: Binding<Double>,
         backgroundEnabled: Bool = true,
         backgroundColor: Color = Color(red: 245/255,
                                        green: 245/255,
                                        blue: 245/255),
         foregroundColor: Color = Color.green) {
        self._value = value
        self._maxValue = maxValue
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometryReader in
                if self.backgroundEnabled {
                    Capsule()
                        .foregroundColor(self.backgroundColor) // 4
                }
                    
                Capsule()
                .frame(width: self.progress(value: self.value,
                                            maxValue: self.maxValue,
                                            width: geometryReader.size.width))
                .foregroundColor(self.foregroundColor)
                .animation(.easeIn)
            }
        }.frame(height: 10)
    }
    
    func progress(value: Double, maxValue: Double,
                  width: CGFloat) -> CGFloat {
        let percentage = value / maxValue
        return width *  CGFloat(percentage)
    }
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(value: .constant(50), maxValue: .constant(100))
    }
}

