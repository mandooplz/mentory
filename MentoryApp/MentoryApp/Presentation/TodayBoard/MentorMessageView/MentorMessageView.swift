//
//  MentorMessageView.swift
//  Mentory
//
//  Created by 김민우 on 12/4/25.
//
import Foundation
import MentoryCore
import SwiftUI
import Values

// MARK: View
struct MentorMessageView: View {
    @ObservedObject var mentorMessage: MentorMessage

    var body: some View {
        PopupCard(
            character: mentorMessage.character,
            title: mentorMessage.character?.title,
            defaultTitle: "오늘의 문장을 준비하고 있어요",
            content: mentorMessage.content,
            defaultContent: "잠시 후 오늘의 톤에 맞는 짧은 문장이 도착합니다."
        )
        .task {
            await mentorMessage.updateContent()
        }
    }
}

struct PopupCard: View {
    let character: MentoryCharacter?
    let title: String?
    let defaultTitle: String
    let content: String?
    let defaultContent: String

    private func forMarkdown(_ string: String) -> LocalizedStringKey {
        .init(string)
    }

    var body: some View {
        MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    MentoryToneMark(character: character, size: 38)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title ?? defaultTitle)
                            .mentoryHeadline()
                            .foregroundStyle(.primary)

                        Text(toneLabel)
                            .mentoryEyebrow()
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }

                Text(forMarkdown(content ?? defaultContent))
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var toneLabel: String {
        switch character {
        case .cool:
            return "또렷하게 읽어드릴게요"
        case .warm:
            return "부드럽게 읽어드릴게요"
        case nil:
            return "조금만 기다려주세요"
        }
    }
}

// MARK: Preview
fileprivate struct MentorMessagePreview: View {
    var body: some View {
        Text("프리뷰")
    }
}

#Preview {
    MentorMessagePreview()
}
