//
//  MindAnalyzerLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/24/25.
//
import Foundation
import SwiftUI


// MARK: Layout
struct MindAnalyzerLayout<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.mentoryBackground.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                LiquidGlassCard(cornerRadius: 32) {
                    VStack(alignment: .leading, spacing: 24) {
                        self.content()
                    }
                    .padding(24)
                }
                .padding(.horizontal)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
        }
    }
}
