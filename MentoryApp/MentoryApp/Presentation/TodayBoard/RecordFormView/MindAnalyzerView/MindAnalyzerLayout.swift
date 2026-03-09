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
        MentoryScrollScreen(spacing: 0, topPadding: 28, bottomPadding: 40) {
            MentorySectionCard(cornerRadius: 32, contentPadding: 24) {
                VStack(alignment: .leading, spacing: 24) {
                    self.content()
                }
            }
        }
    }
}
