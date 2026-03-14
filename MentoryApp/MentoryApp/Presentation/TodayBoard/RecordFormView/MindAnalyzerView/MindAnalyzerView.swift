import MentoryCore
//
//  MindAnalyzerView.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//
import SwiftUI
import Values

// MARK: View
struct MindAnalyzerView: View {
    @ObservedObject private(set) var mindAnalyzer: MindAnalyzer

    @State private var showingSubmitAlert = false

    var body: some View {
        MindAnalyzerLayout {
            MentorySectionHeader(
                eyebrow: "읽기",
                title: headerTitle,
                subtitle: headerSubtitle
            )

            switch mindAnalyzer.status {
            case .ready:
                TonePicker(selection: $mindAnalyzer.character)

                AnalyzeButton(
                    label: "이 톤으로 읽기",
                    isDisabled: mindAnalyzer.character == nil || mindAnalyzer.status.isAnalyzing
                ) {
                    showingSubmitAlert = true
                }
                .disabled(mindAnalyzer.character == nil || mindAnalyzer.status.isAnalyzing)
                .alert("이 기록을 정리해볼까요?", isPresented: $showingSubmitAlert) {
                    Button("취소", role: .cancel) {}
                    Button("정리 시작") {
                        Task {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                mindAnalyzer.status = .analyzing
                            }

                            await mindAnalyzer.analyze()
                            await mindAnalyzer.updateSuggestions()
                        }
                    }
                } message: {
                    Text("기록을 천천히 읽고 감정 해석과 다음 제안을 함께 정리합니다.")
                }

                ResultPanel(
                    state: .preview,
                    result: nil,
                    mindType: nil,
                    character: mindAnalyzer.character
                )

            case .analyzing:
                SelectedToneCard(character: mindAnalyzer.character)

                ResultPanel(
                    state: .loading,
                    result: mindAnalyzer.analyzedResult,
                    mindType: mindAnalyzer.mindType,
                    character: mindAnalyzer.character
                )

            case .finished:
                SelectedToneCard(character: mindAnalyzer.character)

                ResultPanel(
                    state: .finished,
                    result: mindAnalyzer.analyzedResult,
                    mindType: mindAnalyzer.mindType,
                    character: mindAnalyzer.character
                )

                ConfirmButton(
                    label: "확인하고 돌아가기",
                    isPresented: mindAnalyzer.status.isAnalyzeFinished
                ) {
                    let recordForm = mindAnalyzer.owner!
                    recordForm.finish()
                    mindAnalyzer.finish()
                }
            }
        }
        .navigationBarBackButtonHidden(!mindAnalyzer.status.isSelectingStage)
    }

    private var headerTitle: String {
        switch mindAnalyzer.status {
        case .ready:
            return "어떤 톤으로 읽을까요?"
        case .analyzing:
            return "기록을 읽고 있어요"
        case .finished:
            return "정리가 준비되었어요"
        }
    }

    private var headerSubtitle: String {
        switch mindAnalyzer.status {
        case .ready:
            return "같은 기록이라도 바라보는 결을 조금 다르게 고를 수 있어요."
        case .analyzing:
            return "조금만 기다리면 감정의 결을 차분히 정리해드릴게요."
        case .finished:
            return "지금의 마음을 먼저 읽고, 오늘 해볼 수 있는 작은 제안으로 이어집니다."
        }
    }
}

extension Emotion {
    fileprivate var title: String {
        switch self {
        case .veryUnpleasant: return "무거움이 길게 남은 하루"
        case .unPleasant: return "불편함이 분명했던 하루"
        case .slightlyUnpleasant: return "작은 걸림이 남아 있는 하루"
        case .neutral: return "담담하게 지나간 하루"
        case .slightlyPleasant: return "은은한 온기가 남은 하루"
        case .pleasant: return "좋은 흐름이 이어진 하루"
        case .veryPleasant: return "활기가 크게 살아난 하루"
        }
    }

    fileprivate var description: String {
        switch self {
        case .veryUnpleasant:
            return "회복이 먼저 필요한 날이었어요. 너무 잘 해내려 하기보다 마음을 덜어내는 선택이 중요해 보여요."
        case .unPleasant:
            return "긴장이나 피로가 또렷하게 남아 있었어요. 부담을 조금 줄여주는 움직임이 도움이 될 수 있어요."
        case .slightlyUnpleasant:
            return "크지는 않지만 무시하기 어려운 불편함이 남아 있어요. 짧게라도 정리해두면 한결 가벼워질 수 있어요."
        case .neutral:
            return "감정의 파도가 크지 않았어요. 지금의 균형을 무리 없이 이어가는 것이 중요해 보여요."
        case .slightlyPleasant:
            return "작지만 분명한 안도감이 있었어요. 오늘 잘 맞았던 리듬을 기억해두면 좋겠어요."
        case .pleasant:
            return "좋은 에너지가 또렷하게 살아 있었어요. 이 흐름을 유지할 작은 행동이 도움이 될 수 있어요."
        case .veryPleasant:
            return "활기와 만족감이 강하게 느껴졌어요. 이 감정을 오래 남길 방법을 하나쯤 붙잡아두면 좋아요."
        }
    }

    fileprivate var tint: Color {
        switch self {
        case .veryUnpleasant: return .red.opacity(0.72)
        case .unPleasant: return .orange.opacity(0.76)
        case .slightlyUnpleasant: return .yellow.opacity(0.8)
        case .neutral: return .gray.opacity(0.7)
        case .slightlyPleasant: return .mint.opacity(0.78)
        case .pleasant: return .blue.opacity(0.74)
        case .veryPleasant: return .purple.opacity(0.72)
        }
    }
}

// MARK: Component
private struct TonePicker: View {
    @Binding var selection: MentoryCharacter?

    var body: some View {
        VStack(spacing: 12) {
            ForEach(MentoryCharacter.allCases, id: \.self) { character in
                ToneCard(
                    character: character,
                    isSelected: character == selection
                ) {
                    withAnimation(.easeOut(duration: 0.18)) {
                        selection = character
                    }
                }
            }
        }
    }
}

private struct ToneCard: View {
    let character: MentoryCharacter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                MentoryToneMark(character: character, size: 42)

                VStack(alignment: .leading, spacing: 6) {
                    Text(character.displayName)
                        .mentoryHeadline()
                        .foregroundStyle(.primary)

                    Text(character.description)
                        .mentorySupportText()
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.mentoryAccentPrimary : .secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? Color.mentoryCard.opacity(0.98) : Color.mentorySubCard.opacity(0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        isSelected ? Color.mentoryAccentPrimary.opacity(0.4) : Color.mentoryBorder.opacity(0.78),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SelectedToneCard: View {
    let character: MentoryCharacter?

    var body: some View {
        if let character {
            HStack(spacing: 14) {
                MentoryToneMark(character: character, size: 38)

                VStack(alignment: .leading, spacing: 4) {
                    Text(character.displayName)
                        .mentoryHeadline()
                        .foregroundStyle(.primary)

                    Text(character.title)
                        .mentorySupportText()
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.mentoryCard.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.mentoryBorder.opacity(0.82), lineWidth: 1)
            )
        }
    }
}

private struct AnalyzeButton: View {
    let label: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
        }
        .buttonStyle(MentoryPrimaryButtonStyle(isEnabled: !isDisabled))
    }
}

private struct ResultPanel: View {
    enum State {
        case preview
        case loading
        case finished
    }

    let state: State
    let result: String?
    let mindType: Emotion?
    let character: MentoryCharacter?

    var body: some View {
        switch state {
        case .preview:
            MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("이 기록은 곧 이런 순서로 정리돼요.")
                        .mentoryHeadline()
                        .foregroundStyle(.primary)

                    VStack(alignment: .leading, spacing: 10) {
                        AnalysisHighlightRow(title: "감정의 결", description: "오늘의 마음이 어떤 흐름이었는지 읽어요.")
                        AnalysisHighlightRow(title: "짧은 해석", description: "기록을 한두 단락으로 차분히 정리해요.")
                        AnalysisHighlightRow(title: "다음 한 걸음", description: "지금 해볼 수 있는 작은 제안으로 이어져요.")
                    }
                }
            }

        case .loading:
            MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.mentoryAccentPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("천천히 읽고 있어요")
                                .mentoryHeadline()
                                .foregroundStyle(.primary)

                            Text("문장 사이에 남아 있는 감정과 맥락을 정리하는 중입니다.")
                                .mentorySupportText()
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(character == .cool ? "또렷한 시선으로 핵심을 정리하고 있어요." : "다정한 시선으로 마음의 결을 살피고 있어요.")
                        .mentorySupportText()
                        .foregroundStyle(.secondary)
                }
            }

        case .finished:
            VStack(spacing: 14) {
                if let mindType {
                    EmotionSummaryCard(mindType: mindType)
                }

                MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("오늘의 정리")
                            .mentoryHeadline()
                            .foregroundStyle(.primary)

                        Text(result ?? "")
                            .mentorySupportText()
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

private struct EmotionSummaryCard: View {
    let mindType: Emotion

    var body: some View {
        MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
            HStack(spacing: 16) {
                Circle()
                    .fill(mindType.tint.opacity(0.18))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(mindType.emoji)
                            .font(.system(.title3, design: .rounded, weight: .regular))
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(mindType.title)
                        .mentoryHeadline()
                        .foregroundStyle(.primary)

                    Text(mindType.description)
                        .mentorySupportText()
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
    }
}

private struct AnalysisHighlightRow: View {
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.mentoryAccentPrimary)
                .frame(width: 6, height: 6)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(description)
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ConfirmButton: View {
    let label: String
    let isPresented: Bool
    let action: () -> Void

    var body: some View {
        if isPresented {
            Button(action: action) {
                Text(label)
            }
            .buttonStyle(MentoryPrimaryButtonStyle())
        }
    }
}

// MARK: Preview
private struct MindAnalyzerPreview: View {
    @StateObject private var mentoryiOS = Mentory()

    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard,
           let recordForm = todayBoard.recordForms.first,
           let mindAnalyzer = recordForm.mindAnalyzer {
            MindAnalyzerView(mindAnalyzer: mindAnalyzer)
        } else {
            ProgressView("프리뷰 로딩 중입니다.")
                .task {
                    mentoryiOS.setUp()

                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김깝십"
                    onboarding.submitForm()

                    let todayBoard = mentoryiOS.todayBoard!

                    await todayBoard.setUpRecordForms()
                    let recordForm = todayBoard.recordForms.first!

                    recordForm.titleInput = "SAMPLE-TITLE"
                    recordForm.textInput = "SAMPLE-TEXT"

                    await recordForm.submit()
                }
        }
    }
}

#Preview {
    MindAnalyzerPreview()
}
