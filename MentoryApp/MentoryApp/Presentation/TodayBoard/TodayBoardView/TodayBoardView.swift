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
                    eyebrow: "멘토 메시지",
                    title: "오늘의 멘토 한마디",
                    subtitle: "기록을 시작하기 전에 짧게 확인해보세요."
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
                MentoryInfoChip(text: "오늘 기록", systemImage: "heart.text.square")

                Text("\(userName)님의 오늘 기록")
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
            return "기록과 추천 행동을 불러오고 있습니다."
        }

        if recordCount == 0 {
            return "첫 기록을 남기면 감정 리포트와 행동 제안이 함께 정리됩니다."
        }

        return "지금까지 \(recordCount)개의 기록이 저장되어 있어요. 오늘 기록도 이어서 정리해보세요."
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
            defaultContent: "잠시 후 오늘 기록에 맞는 멘토 메시지가 표시됩니다.\n기록을 시작하기 전에 가볍게 확인해보세요."
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
                eyebrow: "기록",
                title: "기록 작성",
                subtitle: "최근 3일 중 작성 가능한 날짜를 선택할 수 있습니다."
            )

            MentorySectionCard(cornerRadius: 32, contentPadding: 22) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(recordCardTitle)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
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
            return "최근 기록을 모두 작성했어요"
        case 1:
            return "작성 가능한 기록이 1개 남아 있어요"
        default:
            return "작성 가능한 기록이 \(availableRecordCount)개 남아 있어요"
        }
    }

    private var recordCardDescription: String {
        switch availableRecordCount {
        case 0:
            return "오늘, 어제, 그제의 작성 상태를 다시 확인할 수 있습니다."
        case 1:
            return "남은 기록을 작성하면 오늘의 흐름을 정리할 수 있습니다."
        default:
            return "필요하면 사진과 음성을 함께 남겨 기록 맥락을 보완해보세요."
        }
    }
}

private struct RecordAvailabilityPill: View {
    @ObservedObject var recordForm: RecordForm

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(relativeLabel)
                .font(.system(size: 12, weight: .medium, design: .rounded))
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
                    eyebrow: "추천 행동",
                    title: "오늘의 행동 제안",
                    subtitle: todayBoard.suggestions.isEmpty
                        ? "기록을 마치면 오늘 해볼 행동이 여기에 표시됩니다."
                        : "하나씩 완료하면서 오늘의 흐름을 정리해보세요."
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
                                .font(.system(size: 16, weight: .medium, design: .rounded))
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
            return "기록을 제출하면 행동 제안이 생성됩니다."
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
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)

            Text("감정 기록을 마치면 분석 결과를 바탕으로 행동 제안이 정리됩니다.")
                .mentorySupportText()
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                SuggestionHintRow(text: "감정 상태에 맞는 행동을 제안합니다.")
                SuggestionHintRow(text: "완료 여부를 바로 표시할 수 있습니다.")
                SuggestionHintRow(text: "완료 횟수에 따라 뱃지가 쌓입니다.")
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
                    eyebrow: "뱃지",
                    title: "획득한 뱃지",
                    subtitle: "추천 행동 완료 수에 따라 뱃지가 쌓입니다."
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
                    eyebrow: "날짜 선택",
                    title: "작성할 날짜를 선택하세요",
                    subtitle: "최근 3일 중 아직 작성하지 않은 날짜를 선택할 수 있습니다."
                )

                if todayBoard.recordForms.isEmpty {
                    MentoryStatusCard(
                        systemImage: "checkmark.circle.fill",
                        title: "모든 기록이 완료되었어요",
                        message: "최근 3일의 기록을 모두 작성했습니다. 다음 기록은 새로운 날짜가 열리면 이어서 남길 수 있어요.",
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
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(recordForm.isDisabled ? "이미 작성한 날짜예요" : date.formatted())
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(recordForm.isDisabled ? "완료" : "작성")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(recordForm.isDisabled ? .secondary : Color.mentoryAccentPrimary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
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
