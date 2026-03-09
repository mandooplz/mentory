//
//  RecordFormLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/24/25.
//
import SwiftUI
import UIKit


// MARK: Layout
struct RecordFormLayout<ToolBar: CustomizableToolbarContent, TodayDate: View, Main: View, BottomBar: View>: View {
    @ToolbarContentBuilder let topBar: () -> ToolBar
    @ViewBuilder let todayDate: () -> TodayDate
    @ViewBuilder let main: () -> Main
    @ViewBuilder let bottomBar: () -> BottomBar
    
    var body: some View {
        NavigationStack {
            ZStack {
                MentoryBackdrop()

                VStack(spacing: 0) {
                    self.todayDate()
                        .padding(.horizontal, MentorySpacing.screenHorizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 4)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            self.main()
                        }
                        .padding(.horizontal, MentorySpacing.screenHorizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 88)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onTapGesture {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                }
            }
            .toolbar {
                self.topBar()

                ToolbarItemGroup(placement: .bottomBar) {
                    self.bottomBar()
                }
            }
            .toolbarBackground(Color.mentoryCard.opacity(0.96), for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
