//
//  TodayBoardLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/23/25.
//
import Foundation
import SwiftUI
import WebKit


// MARK: Layout
struct TodayBoardLayout<Content: View, navDestination: View>: View {
    @ViewBuilder let navDestination: () -> navDestination
    @ViewBuilder let content: () -> Content

    @State private var isShowingInformationView = false
    
    var body: some View {
        NavigationStack {
            MentoryScrollScreen(spacing: 24, topPadding: 18, bottomPadding: 40) {
                self.content()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MentoryToolbarIconButton(
                        systemName: "info.circle",
                        accessibilityLabel: "정보 열기"
                    ) {
                        isShowingInformationView = true
                    }
                }
            }
            .sheet(isPresented: $isShowingInformationView) {
                self.navDestination()
            }
        }
    }
}
