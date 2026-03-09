import Combine
import MentoryCore
//
//  TodayBoardView.swift
//  Mentory
//
//  Created by JAY on 11/14/25.
//
import SwiftUI
import Values
import WebKit

// MARK: View
struct TodayBoardView: View {
    @ObservedObject var todayBoard: TodayBoard
    @ObservedObject var mentoryiOS: Mentory

    var body: some View {
        TodayBoardLayout(
            navDestination: {
                WebView(url: todayBoard.owner!.informationURL.rawValue)
            }
        ) {
            DashboardHeroHeader(
                todayBoard: todayBoard,
                userName: mentoryiOS.userName ?? "익명"
            )

            VStack(alignment: .leading, spacing: 12) {
                MentorySectionHeader(
                    eyebrow: "TODAY MESSAGE",
                    title: "오늘의 멘토 한마디",
                    subtitle: "작성 흐름에 들어가기 전에 오늘의 조언으로 감정 상태를 정리해보세요."
                )

                MessageView(mentorMessage: todayBoard.mentorMessage)
            }

            RecordComposerSection(todayBoard: todayBoard)

            SuggestionSection(todayBoard: todayBoard)
        }
        .task {
            if todayBoard.mentorMessage == nil {
                await todayBoard.setUpMentorMessage()
            }

            if todayBoard.recordForms.isEmpty {
                await todayBoard.setUpRecordForms()
            }

            for recordForm in todayBoard.recordForms {
                await recordForm.checkDisability()
            }
        }
    }
}

// MARK: Preview
private struct TodayBoardPreview: View {
    @StateObject var mentoryiOS = Mentory()

    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard {
            TodayBoardView(
                todayBoard: todayBoard,
                mentoryiOS: todayBoard.owner!
            )
        } else {
            ProgressView("프리뷰 준비 중")
                .task {
                    mentoryiOS.setUp()

                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김철수"
                    onboarding.submitForm()
                }
        }
    }
}

#Preview {
    TodayBoardPreview()
}

// MARK: Component
private struct DashboardHeroHeader: View {
    @ObservedObject var todayBoard: TodayBoard
    let userName: String

    var body: some View {
        MentorySectionCard(cornerRadius: 34, contentPadding: 24) {
            VStack(alignment: .leading, spacing: 18) {
                MentoryInfoChip(text: "MENTORY DAILY", systemImage: "heart.text.square")

                Text("\(userName)님의 감정 흐름을 정리할 시간이에요")
                    .mentoryTitle()
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(greetingCopy)
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    MentoryMetricPill(
                        title: "오늘",
                        value: todayBoard.currentDate.formatted()
                    )
                    MentoryMetricPill(
                        title: "누적 기록",
                        value: recordCountLabel
                    )
                    MentoryMetricPill(
                        title: "추천 진행",
                        value: suggestionProgressLabel
                    )
                }
            }
        }
        .task {
            await todayBoard.fetchUserRecordCount()
        }
    }

    private var greetingCopy: String {
        guard let recordCount = todayBoard.recordCount else {
            return "오늘의 기록과 추천 행동을 준비하고 있어요. 잠시 후 개인화된 흐름이 채워집니다."
        }

        if recordCount == 0 {
            return "첫 기록을 시작하면 감정 흐름과 행동 제안이 함께 쌓이기 시작합니다."
        }

        return "\(recordCount)번의 기록이 누적되었어요. 오늘의 흐름도 차분하게 이어가볼까요?"
    }

    private var recordCountLabel: String {
        guard let recordCount = todayBoard.recordCount else {
            return "불러오는 중"
        }

        return "\(recordCount)회"
    }

    private var suggestionProgressLabel: String {
        guard todayBoard.suggestions.isEmpty == false else {
            return "대기"
        }

        return todayBoard.getSuggestionIndicator()
    }
}

struct MessageView: View {
    let mentorMessage: MentorMessage?

    var body: some View {
        if let mentorMessage {
            MentorMessageView(mentorMessage: mentorMessage)
        } else {
            MentorMessageDefaultView()
        }
    }
}

struct MentorMessageDefaultView: View {
    var body: some View {
        PopupCard(
            image: nil,
            defaultImage: "greeting",
            title: nil,
            defaultTitle: "오늘의 멘토 메시지를 준비하고 있어요",
            content: nil,
            defaultContent: "잠시 후 당신을 위한 멘토 한마디가 도착해요.\n오늘은 어떤 시선으로 하루를 정리하면 좋을지 함께 살펴볼게요."
        )
    }
}

private struct RecordComposerSection<Content: View>: View {
    @ObservedObject var todayBoard: TodayBoard
    @State private var showDateSelectionSheet = false

    @ViewBuilder let navDestination: (RecordForm) -> Content

    init(
        todayBoard: TodayBoard,
        @ViewBuilder navDestination: @escaping (RecordForm) -> Content = { recordForm in
            RecordFormView(recordForm: recordForm)
        }
    ) {
        self.todayBoard = todayBoard
        self.navDestination = navDestination
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MentorySectionHeader(
                eyebrow: "RECORD FLOW",
                title: "오늘의 기록 시작하기",
                subtitle: "최근 3일 중 작성 가능한 날짜를 선택해 텍스트, 사진, 음성까지 함께 기록할 수 있어요."
            )

            MentorySectionCard(cornerRadius: 32, contentPadding: 22) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(recordCardTitle)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)

                            Text(recordCardDescription)
                                .mentorySupportText()
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)

                        Image("greeting")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                    }

                    if todayBoard.recordForms.isEmpty == false {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(todayBoard.recordForms) { recordForm in
                                    RecordAvailabilityPill(recordForm: recordForm)
                                }
                            }
                        }
                    }

                    Button {
                        Task {
                            if todayBoard.recordForms.isEmpty {
                                await todayBoard.setUpRecordForms()
                            }

                            for recordForm in todayBoard.recordForms {
                                await recordForm.checkDisability()
                            }

                            showDateSelectionSheet = true
                        }
                    } label: {
                        Text(availableRecordCount == 0 ? "작성 가능한 날짜 확인" : "기록 시작하기")
                    }
                    .buttonStyle(MentoryPrimaryButtonStyle())
                }
            }
        }
        .sheet(isPresented: $showDateSelectionSheet) {
            DateSelectionSheet(todayBoard: todayBoard)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(
            item: $todayBoard.recordFormSelection,
            content: { recordForm in
                navDestination(recordForm)
            }
        )
    }

    private var availableRecordCount: Int {
        todayBoard.recordForms.filter { $0.isDisabled == false }.count
    }

    private var recordCardTitle: String {
        switch availableRecordCount {
        case 0:
            return "최근 기록이 모두 정리됐어요"
        case 1:
            return "오늘 기록이 하나 남아 있어요"
        default:
            return "\(availableRecordCount)개의 기록 기회가 남아 있어요"
        }
    }

    private var recordCardDescription: String {
        switch availableRecordCount {
        case 0:
            return "오늘, 어제, 그제의 기록을 모두 작성했어요. 날짜를 열어 작성 상태를 확인할 수 있습니다."
        case 1:
            return "지금 남은 한 번의 기록으로 오늘의 감정 흐름을 완성해보세요."
        default:
            return "텍스트에 사진과 음성을 더하면 감정 맥락을 더 입체적으로 남길 수 있어요."
        }
    }
}

private struct RecordAvailabilityPill: View {
    @ObservedObject var recordForm: RecordForm

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(relativeLabel)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            Text(recordForm.isDisabled ? "작성 완료" : "작성 가능")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(recordForm.isDisabled ? .secondary : Color.mentoryAccentPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(recordForm.isDisabled ? Color.mentoryCard.opacity(0.7) : Color.mentoryAccentPrimary.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    recordForm.isDisabled
                        ? Color.white.opacity(0.16)
                        : Color.mentoryAccentPrimary.opacity(0.18),
                    lineWidth: 1
                )
        )
    }

    private var relativeLabel: String {
        let relativeDay = recordForm.targetDate.relativeDay(from: .now)
        if relativeDay == .unknown {
            return recordForm.targetDate.formatted()
        }

        return relativeDay.rawValue
    }
}

private struct SuggestionSection: View {
    @ObservedObject var todayBoard: TodayBoard
    @State private var isFlipped = false
    @State private var initialBadgeCount: Int = 0

    private var hasNewBadge: Bool {
        todayBoard.earnedBadges.count > initialBadgeCount
    }

    var body: some View {
        Group {
            if isFlipped {
                BadgeBackCard(
                    todayBoard: todayBoard,
                    onClose: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                            isFlipped = false
                        }
                    }
                )
            } else {
                SuggestionFrontCard(
                    todayBoard: todayBoard,
                    hasNewBadge: hasNewBadge,
                    onOpenBadge: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                            isFlipped = true
                        }
                    }
                )
            }
        }
        .task {
            await todayBoard.fetchEarnedBadges()
            await todayBoard.loadSuggestions()

            if initialBadgeCount == 0 {
                initialBadgeCount = todayBoard.earnedBadges.count
            }
        }
        .task(id: isFlipped) {
            if isFlipped {
                initialBadgeCount = todayBoard.earnedBadges.count
            }
        }
    }
}

private struct SuggestionFrontCard: View {
    @ObservedObject var todayBoard: TodayBoard
    let hasNewBadge: Bool
    let onOpenBadge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                MentorySectionHeader(
                    eyebrow: "ACTION PLAN",
                    title: "오늘의 추천 루틴",
                    subtitle: todayBoard.suggestions.isEmpty
                        ? "기록을 제출하면 감정 흐름에 맞는 행동 제안이 여기에 채워집니다."
                        : "추천 행동을 하나씩 완료하면서 오늘의 회복 루틴을 만들어보세요."
                )

                Button(action: onOpenBadge) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 34, height: 34)

                        if hasNewBadge {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .buttonStyle(MentoryIconButtonStyle())
                .accessibilityLabel("획득한 뱃지 보기")
            }

            MentorySectionCard(cornerRadius: 32, contentPadding: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(todayBoard.suggestions.isEmpty ? "대기 중" : "진행 현황")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text(progressSummary)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }

                        Spacer()

                        Text(progressIndicator)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    progressBar

                    if todayBoard.suggestions.isEmpty {
                        SuggestionEmptyState()
                    } else {
                        VStack(spacing: 10) {
                            ForEach(todayBoard.suggestions, id: \.self.id) { suggestion in
                                SuggestionView(suggestion: suggestion)
                            }
                        }
                    }
                }
            }
        }
    }

    private var progressSummary: String {
        if todayBoard.suggestions.isEmpty {
            return "기록 제출 후 행동 제안 3개가 생성돼요"
        }

        return "\(Int(todayBoard.suggestionProgress * 100))% 완료"
    }

    private var progressIndicator: String {
        guard todayBoard.suggestions.isEmpty == false else {
            return "아직 없음"
        }

        return todayBoard.getSuggestionIndicator()
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.mentoryProgressTrack)
                    .frame(height: 12)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.mentoryAccentPrimary,
                                Color.mentoryAccentSecondary.opacity(0.92),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * max(todayBoard.suggestionProgress, 0.04),
                        height: 12
                    )
                    .animation(.spring(response: 0.42, dampingFraction: 0.8), value: todayBoard.suggestionProgress)
            }
        }
        .frame(height: 12)
    }
}

private struct SuggestionEmptyState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("아직 추천 행동이 없어요")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("감정 기록을 마치면 분석 결과를 바탕으로 지금 해볼 만한 행동 제안이 자동으로 정리됩니다.")
                .mentorySupportText()
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                SuggestionHintRow(text: "감정 상태에 맞는 행동 3가지를 제안")
                SuggestionHintRow(text: "완료 여부를 체크하며 루틴처럼 사용")
                SuggestionHintRow(text: "완료 횟수에 따라 뱃지가 누적")
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.mentorySubCard.opacity(0.82))
        )
    }
}

private struct SuggestionHintRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.mentoryAccentPrimary)
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

private struct BadgeBackCard: View {
    @ObservedObject var todayBoard: TodayBoard
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                MentorySectionHeader(
                    eyebrow: "BADGE COLLECTION",
                    title: "획득한 뱃지",
                    subtitle: "추천 행동을 완료할수록 감정 케어 루틴이 누적되고 새로운 뱃지가 열립니다."
                )

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(MentoryIconButtonStyle())
                .accessibilityLabel("뱃지 화면 닫기")
            }

            MentorySectionCard(cornerRadius: 32, contentPadding: 20) {
                BadgeGridView(
                    earnedBadges: todayBoard.earnedBadges,
                    completedCount: todayBoard.completedSuggestionsCount
                )
            }
        }
    }
}

// MARK: - DateSelectionSheet
private struct DateSelectionSheet: View {
    @ObservedObject var todayBoard: TodayBoard
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            MentoryScrollScreen(spacing: 18, topPadding: 20, bottomPadding: 24) {
                MentorySectionHeader(
                    eyebrow: "DATE PICKER",
                    title: "어느 날의 기록을 남길까요?",
                    subtitle: "오늘, 어제, 그제 중 아직 작성하지 않은 날짜를 선택해 기록을 이어갈 수 있어요."
                )

                if todayBoard.recordForms.isEmpty {
                    MentoryStatusCard(
                        systemImage: "checkmark.circle.fill",
                        title: "모든 기록이 완료되었어요",
                        message: "최근 3일의 기록을 모두 남겼습니다. 내일 새로운 흐름이 열리면 다시 이어서 작성해보세요.",
                        tint: .green
                    )
                } else {
                    MentorySectionCard(cornerRadius: 28, contentPadding: 16) {
                        VStack(spacing: 12) {
                            ForEach(todayBoard.recordForms) { recordForm in
                                DateButton(
                                    recordForm: recordForm,
                                    date: recordForm.targetDate,
                                    action: {
                                        todayBoard.recordFormSelection = recordForm
                                        dismiss()
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MentoryToolbarIconButton(
                        systemName: "xmark",
                        accessibilityLabel: "날짜 선택 닫기"
                    ) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(460), .large])
    }
}

private struct DateButton: View {
    @ObservedObject var recordForm: RecordForm
    let date: MentoryDate
    let action: () -> Void

    var body: some View {
        Button {
            if recordForm.isDisabled == false {
                action()
            }
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(date.relativeDay(from: .now).rawValue.isEmpty ? date.formatted() : date.relativeDay(from: .now).rawValue)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(recordForm.isDisabled ? "이미 작성한 날짜예요" : date.formatted())
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(recordForm.isDisabled ? "완료" : "작성")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(recordForm.isDisabled ? .secondary : Color.mentoryAccentPrimary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(recordForm.isDisabled ? Color.mentoryCard.opacity(0.8) : Color.mentorySubCard.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        recordForm.isDisabled
                            ? Color.white.opacity(0.15)
                            : Color.mentoryAccentPrimary.opacity(0.16),
                        lineWidth: 1
                    )
            )
            .opacity(recordForm.isDisabled ? 0.68 : 1.0)
        }
        .buttonStyle(.plain)
        .task {
            await recordForm.checkDisability()
        }
    }
}
