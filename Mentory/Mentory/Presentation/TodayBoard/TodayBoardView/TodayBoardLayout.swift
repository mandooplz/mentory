//
//  TodayBoardLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/23/25.
//
import Foundation
import SwiftUI


// MARK: Layout
struct TodayBoardLayout<Content:View, TContent: ToolbarContent>: View {
    let content: Content
    let toolbarContent: TContent
    
    init(@ViewBuilder content: () -> Content,
         @ToolbarContentBuilder toolbarContent: () -> TContent) {
        self.content = content()
        self.toolbarContent = toolbarContent()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GrayBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        self.content
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                self.toolbarContent
            }
        }
    }
}


// MARK: Component
fileprivate struct GrayBackground: View {
    var body: some View {
        Color(.systemGray6)
            .ignoresSafeArea()
    }
}
