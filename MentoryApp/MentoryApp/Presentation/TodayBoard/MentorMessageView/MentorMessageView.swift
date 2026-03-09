//
//  MentorMessageView.swift
//  Mentory
//
//  Created by 김민우 on 12/4/25.
//
import Foundation
import SwiftUI
import Values
import MentoryCore



// MARK: View
struct MentorMessageView: View {
    // MARK: model
    @ObservedObject var mentorMessage: MentorMessage
    
    
    // MARK: body
    var body: some View {
        PopupCard(
            image: mentorMessage.character?.imageName,
            defaultImage: "greeting",
            title: mentorMessage.character?.title,
            defaultTitle: "오늘의 멘토리 조언을 준비하고 있어요",
            content: mentorMessage.content,
            defaultContent: "잠시 후 당신을 위한 멘토리 메시지가 도착해요\n오늘은 냉철이일까요, 구름이일까요?\n조금만 기다려 주세요"
        )
        .task {
            await mentorMessage.updateContent()
        }
    }
}

struct PopupCard: View {
    let image: String?
    let defaultImage: String
    let title: String?
    let defaultTitle: String
    let content: String?
    let defaultContent: String
    
    private func forMarkdown(_ string: String) -> LocalizedStringKey {
        .init(string)
    }
    
    var body: some View {
        MentorySectionCard(cornerRadius: 30, contentPadding: 22) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    Image(image ?? defaultImage)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(1.8, anchor: .top)
                        .offset(y: 2)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        MentoryInfoChip(text: "오늘의 멘토 메모", systemImage: "sparkles")

                        Text(title ?? defaultTitle)
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }

                    Spacer(minLength: 0)
                }

                Text(forMarkdown(content ?? defaultContent))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .transition(.scale(scale: 0.95).combined(with: .opacity))
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
