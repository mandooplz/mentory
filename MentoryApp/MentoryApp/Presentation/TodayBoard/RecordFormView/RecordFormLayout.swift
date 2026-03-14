//
//  RecordFormLayout.swift
//  Mentory
//
//  Created by 김민우 on 11/24/25.
//
import SwiftUI
import UIKit

// MARK: Layout
struct RecordFormLayout<TodayDate: View, Main: View, BottomBar: View>: View {
    @ViewBuilder let todayDate: () -> TodayDate
    @ViewBuilder let main: () -> Main
    @ViewBuilder let bottomBar: () -> BottomBar

    var body: some View {
        ZStack {
            MentoryBackdrop()

            VStack(spacing: 0) {
                todayDate()
                    .padding(.horizontal, MentorySpacing.screenHorizontal)
                    .padding(.top, 18)
                    .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        main()
                    }
                    .padding(.horizontal, MentorySpacing.screenHorizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 120)
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
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 18) {
                bottomBar()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.mentoryCard.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.mentoryBorder.opacity(0.82), lineWidth: 1)
                    )
            )
            .padding(.horizontal, MentorySpacing.screenHorizontal)
            .padding(.bottom, 10)
            .background(Color.clear)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
