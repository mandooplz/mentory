//
//  SuggestionView.swift
//  Mentory
//
//  Created by 김민우 on 12/4/25.
//
import Foundation
import MentoryCore
import SwiftUI

// MARK: View
struct SuggestionView: View {
    @ObservedObject var suggestion: Suggestion

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.18)) {
                suggestion.isDone = true
            }

            Task {
                await suggestion.markDone()
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                completionIndicator

                VStack(alignment: .leading, spacing: 6) {
                    Text(suggestion.content.isEmpty ? " " : suggestion.content)
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(suggestion.isDone ? .secondary : .primary)
                        .multilineTextAlignment(.leading)
                        .strikethrough(suggestion.isDone, color: .secondary)

                    Text(suggestion.isDone ? "마쳤어요" : "끝나면 체크할 수 있어요")
                        .mentoryEyebrow()
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(backgroundShape)
            .overlay(backgroundOverlay)
        }
        .buttonStyle(.plain)
        .disabled(suggestion.isDone)
        .accessibilityHint(suggestion.isDone ? "이미 완료된 제안입니다" : "제안을 완료로 표시합니다")
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
                            lineWidth: suggestion.isDone ? 0 : 1.5
                        )
                )

            Image(systemName: suggestion.isDone ? "checkmark" : "circle.fill")
                .font(.system(suggestion.isDone ? .caption : .caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(suggestion.isDone ? .white : Color.mentoryBorder.opacity(0.7))
        }
    }

    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(suggestion.isDone ? Color.mentorySubCard.opacity(0.82) : Color.mentoryCard.opacity(0.96))
    }

    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(
                suggestion.isDone
                    ? Color.mentoryAccentPrimary.opacity(0.22)
                    : Color.mentoryBorder.opacity(0.75),
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
