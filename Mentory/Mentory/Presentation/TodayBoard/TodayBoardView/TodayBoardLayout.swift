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
struct TodayBoardLayout<Content:View>: View {
    let content: Content

    @State private var isShowingInformationView = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingInformationView = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $isShowingInformationView) {
                WebView(url: MentoryiOS().informationURL)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("닫기") {
                                isShowingInformationView = false
                            }
                        }
                    }
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
