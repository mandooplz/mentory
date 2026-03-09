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
    @Namespace private var mentorNamespace

    var body: some View {
        MindAnalyzerLayout {
            MentorySectionHeader(
                eyebrow: "ANALYSIS FLOW",
                title: headerTitle,
                subtitle: headerSubtitle
            )

            switch mindAnalyzer.status {
            case .ready:
                CharacterPicker(
                    characters: MentoryCharacter.allCases,
                    selection: $mindAnalyzer.character,
                    namespace: mentorNamespace
                )

                AnalyzeButton(
                    label: mindAnalyzer.status.isAnalyzing ? "분석 중" : "리포트 생성하기",
                    isDisabled: mindAnalyzer.character == nil || mindAnalyzer.status.isAnalyzing
                ) {
                    showingSubmitAlert = true
                }
                .disabled(mindAnalyzer.character == nil || mindAnalyzer.status.isAnalyzing)
                .alert("기록을 분석할까요?", isPresented: $showingSubmitAlert) {
                    Button("취소", role: .cancel) {}
                    Button("분석 시작") {
                        Task {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                                mindAnalyzer.status = .analyzing
                            }

                            await mindAnalyzer.analyze()
                            await mindAnalyzer.updateSuggestions()
                        }
                    }
                } message: {
                    Text("분석을 시작하면 오늘 기록을 기준으로 감정 리포트와 행동 제안을 생성합니다.")
                }

                ResultPanel(
                    readyPrompt: "멘토를 선택하면 감정 해석, 공감 메시지, 행동 제안을 한 번에 정리한 리포트가 생성됩니다.",
                    progressPrompt: "선택한 멘토가 기록을 읽고 감정 흐름을 분석하고 있어요.",
                    isProgress: false,
                    result: mindAnalyzer.analyzedResult,
                    mindType: mindAnalyzer.mindType
                )
                .allowsHitTesting(false)

            case .analyzing:
                SelectedMentorCard(
                    character: mindAnalyzer.character,
                    namespace: mentorNamespace
                )

                ResultPanel(
                    readyPrompt: "멘토를 선택하면 감정 해석, 공감 메시지, 행동 제안을 한 번에 정리한 리포트가 생성됩니다.",
                    progressPrompt: "선택한 멘토가 기록을 읽고 감정 흐름을 분석하고 있어요.",
                    isProgress: true,
                    result: mindAnalyzer.analyzedResult,
                    mindType: mindAnalyzer.mindType
                )

            case .finished:
                SelectedMentorCard(
                    character: mindAnalyzer.character,
                    namespace: mentorNamespace
                )

                ResultPanel(
                    readyPrompt: "멘토를 선택하면 감정 해석, 공감 메시지, 행동 제안을 한 번에 정리한 리포트가 생성됩니다.",
                    progressPrompt: "선택한 멘토가 기록을 읽고 감정 흐름을 분석하고 있어요.",
                    isProgress: false,
                    result: mindAnalyzer.analyzedResult,
                    mindType: mindAnalyzer.mindType
                )

                ConfirmButton(
                    icon: "checkmark.circle.fill",
                    label: "오늘 기록 마무리하기",
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
            return "어떤 멘토의 시선으로 정리할까요?"
        case .analyzing:
            return "리포트를 정리하고 있어요"
        case .finished:
            return "오늘의 감정 리포트가 완성됐어요"
        }
    }

    private var headerSubtitle: String {
        switch mindAnalyzer.status {
        case .ready:
            return "멘토를 선택하면 같은 기록도 다른 톤과 시선으로 정리됩니다. 오늘의 마음에 더 잘 맞는 쪽을 골라보세요."
        case .analyzing:
            return "기록, 감정, 첨부 자료를 함께 읽으며 오늘의 핵심 정서를 정리하고 있습니다."
        case .finished:
            return "분석 결과를 확인하고 오늘의 행동 제안까지 이어서 점검해보세요."
        }
    }
}

extension Emotion {
    fileprivate var title: String {
        switch self {
        case .veryUnpleasant: return "매우 무거운 하루"
        case .unPleasant: return "불편함이 큰 하루"
        case .slightlyUnpleasant: return "작은 불편함이 남은 하루"
        case .neutral: return "담담한 하루"
        case .slightlyPleasant: return "잔잔한 온기가 있는 하루"
        case .pleasant: return "긍정 에너지가 흐르는 하루"
        case .veryPleasant: return "만족감이 높은 하루"
        }
    }

    fileprivate var description: String {
        switch self {
        case .veryUnpleasant:
            return "무거운 감정이 오래 머물렀어요. 오늘은 회복에 우선순위를 두는 편이 좋습니다."
        case .unPleasant:
            return "긴장감이나 피로가 크게 남아 있어요. 부담을 줄이는 선택이 필요합니다."
        case .slightlyUnpleasant:
            return "작은 불편함이 마음 한켠에 남아 있어요. 무시하지 말고 짧게라도 정리해보세요."
        case .neutral:
            return "감정의 파도가 크지 않은 차분한 하루예요. 지금의 균형을 유지하는 것이 중요합니다."
        case .slightlyPleasant:
            return "잔잔한 만족감이 흐르고 있어요. 오늘 잘 작동한 패턴을 기억해두면 좋습니다."
        case .pleasant:
            return "긍정적인 에너지가 느껴지는 하루예요. 좋은 흐름을 한 번 더 강화해보세요."
        case .veryPleasant:
            return "설레고 활력이 높은 상태예요. 이 감정을 오래 남길 방법을 찾아보면 좋겠어요."
        }
    }

    fileprivate var tint: Color {
        switch self {
        case .veryUnpleasant: return .red
        case .unPleasant: return .orange
        case .slightlyUnpleasant: return .yellow
        case .neutral: return .gray
        case .slightlyPleasant: return .teal
        case .pleasant: return .blue
        case .veryPleasant: return .purple
        }
    }

    fileprivate var emoji: String {
        switch self {
        case .veryUnpleasant: return "😣"
        case .unPleasant: return "😕"
        case .slightlyUnpleasant: return "🙁"
        case .neutral: return "😐"
        case .slightlyPleasant: return "🙂"
        case .pleasant: return "😄"
        case .veryPleasant: return "🤩"
        }
    }
}

// MARK: Component
private struct CharacterPicker: View {
    let characters: [MentoryCharacter]
    @Binding var selection: MentoryCharacter?
    let namespace: Namespace.ID?

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(characters, id: \.self) { character in
                SelectableCard(
                    character: character,
                    isSelected: character == selection,
                    namespace: namespace,
                    useMatchedGeometry: character == selection
                ) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
                        selection = character
                    }
                }
            }
        }
    }

    fileprivate struct SelectableCard: View {
        let character: MentoryCharacter
        let isSelected: Bool
        let namespace: Namespace.ID?
        let useMatchedGeometry: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                cardContent
            }
            .buttonStyle(.plain)
        }

        @ViewBuilder
        private var cardContent: some View {
            let base = VStack(alignment: .leading, spacing: 14) {
                HStack {
                    MentoryInfoChip(
                        text: isSelected ? "선택됨" : "멘토 선택",
                        systemImage: isSelected ? "checkmark.circle.fill" : "person.crop.circle"
                    )
                    Spacer()
                }

                Image(character.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 6) {
                    Text(character.displayName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(character.description)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        isSelected
                            ? LinearGradient(
                                colors: [
                                    Color.mentoryAccentPrimary.opacity(0.18),
                                    Color.mentoryAccentSecondary.opacity(0.12),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color.mentoryCard,
                                    Color.mentorySubCard.opacity(0.72),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        isSelected
                            ? Color.mentoryAccentPrimary.opacity(0.85)
                            : Color.mentoryBorder.opacity(0.24),
                        lineWidth: isSelected ? 1.8 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color.mentoryAccentPrimary.opacity(0.14) : Color.black.opacity(0.04),
                radius: isSelected ? 18 : 10,
                y: 10
            )

            if let namespace, useMatchedGeometry {
                base.matchedGeometryEffect(id: character, in: namespace)
            } else {
                base
            }
        }
    }
}

private struct SelectedMentorCard: View {
    let character: MentoryCharacter?
    let namespace: Namespace.ID

    var body: some View {
        if let character {
            CharacterPicker.SelectableCard(
                character: character,
                isSelected: true,
                namespace: namespace,
                useMatchedGeometry: true,
                action: {}
            )
            .allowsHitTesting(false)
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
    let readyPrompt: String
    let progressPrompt: String
    let isProgress: Bool
    let result: String?
    let mindType: Emotion?

    var body: some View {
        if isProgress {
            MentorySectionCard(cornerRadius: 30, contentPadding: 22) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.mentoryAccentPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("분석 중")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)

                            Text(progressPrompt)
                                .mentorySupportText()
                                .foregroundStyle(.secondary)
                        }
                    }

                    analysisHighlights
                }
            }
        } else if let result, result.isEmpty == false {
            MentorySectionCard(cornerRadius: 30, contentPadding: 22) {
                VStack(alignment: .leading, spacing: 16) {
                    MentoryInfoChip(text: "ANALYSIS REPORT", systemImage: "waveform.path.ecg")

                    if let mindType {
                        MindTypeResultView(mindType: mindType)
                    }

                    Text(result)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } else {
            MentorySectionCard(cornerRadius: 30, contentPadding: 22) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("리포트 미리보기")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(readyPrompt)
                        .mentorySupportText()
                        .foregroundStyle(.secondary)

                    analysisHighlights
                }
            }
        }
    }

    private var analysisHighlights: some View {
        VStack(alignment: .leading, spacing: 10) {
            AnalysisHighlightRow(title: "감정 해석", description: "오늘의 정서를 한 문장으로 요약")
            AnalysisHighlightRow(title: "공감 메시지", description: "선택한 멘토의 톤으로 정리")
            AnalysisHighlightRow(title: "행동 제안", description: "지금 바로 해볼 수 있는 3가지 추천")
        }
    }

    fileprivate struct MindTypeResultView: View {
        let mindType: Emotion

        var body: some View {
            HStack(spacing: 14) {
                Text(mindType.emoji)
                    .font(.system(size: 38))

                VStack(alignment: .leading, spacing: 4) {
                    Text(mindType.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(mindType.description)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(mindType.tint.opacity(0.14))
            )
        }
    }
}

private struct AnalysisHighlightRow: View {
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.mentoryAccentPrimary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ConfirmButton: View {
    let icon: String
    let label: String
    let isPresented: Bool
    let action: () -> Void

    var body: some View {
        if isPresented {
            Button(action: self.action) {
                HStack(spacing: 8) {
                    Image(systemName: self.icon)
                    Text(self.label)
                }
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
