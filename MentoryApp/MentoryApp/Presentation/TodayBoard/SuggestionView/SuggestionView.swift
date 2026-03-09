//
//  SuggestionView.swift
//  Mentory
//
//  Created by 김민우 on 12/4/25.
//
import Foundation
import SwiftUI
import MentoryCore



// MARK: View
struct SuggestionView: View {
    // MARK: model
    @ObservedObject var suggestion: Suggestion

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                suggestion.isDone = true
            }

            Task {
                await suggestion.markDone()
            }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                completionIndicator

                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.content.isEmpty ? " " : suggestion.content)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(suggestion.isDone ? .secondary : .primary)
                        .multilineTextAlignment(.leading)
                        .strikethrough(suggestion.isDone, color: .secondary)

                    Text(suggestion.isDone ? "완료됨" : "완료로 표시")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(backgroundShape)
            .overlay(backgroundOverlay)
        }
        .buttonStyle(.plain)
        .disabled(suggestion.isDone)
        .accessibilityHint(suggestion.isDone ? "이미 완료된 행동입니다" : "추천 행동을 완료로 표시합니다")
    }

    private var completionIndicator: some View {
        ZStack {
            Circle()
                .fill(suggestion.isDone ? Color.mentoryAccentPrimary : Color.clear)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(
                            suggestion.isDone
                                ? Color.mentoryAccentPrimary
                                : Color.mentoryBorder.opacity(0.9),
                            lineWidth: suggestion.isDone ? 0 : 1.8
                        )
                )

            Image(systemName: suggestion.isDone ? "checkmark" : "circle.fill")
                .font(.system(size: suggestion.isDone ? 12 : 7, weight: .semibold))
                .foregroundStyle(suggestion.isDone ? .white : Color.mentoryBorder.opacity(0.55))
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.72), value: suggestion.isDone)
    }

    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(suggestion.isDone ? Color.mentoryAccentPrimary.opacity(0.1) : Color.mentorySubCard.opacity(0.82))
    }

    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(
                suggestion.isDone
                    ? Color.mentoryAccentPrimary.opacity(0.22)
                    : Color.white.opacity(0.28),
                lineWidth: 1
            )
    }
}


// MARK: Preview
fileprivate struct SuggestionPreview: View {
    var body: some View {
        Text("SuggestionPreview 프리뷰")
    }
}

#Preview {
    SuggestionPreview()
}
