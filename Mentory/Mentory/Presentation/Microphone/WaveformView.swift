//
//  WaveformView.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//


import SwiftUI
import Combine
import AVFoundation
import OSLog

struct WaveformView: View {
    @State private var animationValues: [CGFloat] = Array(repeating: 0.3, count: 20)

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red)
                    .frame(width: 3)
                    .frame(height: CGFloat.random(in: 10...60) * animationValues[index])
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 0.3...0.8))
                            .repeatForever(autoreverses: true),
                        value: animationValues[index]
                    )
            }
        }
        .onAppear {
            for index in 0..<20 {
                animationValues[index] = CGFloat.random(in: 0.3...1.0)
            }
        }
    }
}