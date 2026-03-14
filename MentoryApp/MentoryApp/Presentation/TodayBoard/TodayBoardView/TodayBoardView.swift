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
                WebView(url: todayBoard.owner!.infoURL.rawValue)
            }
        ) {
            TodayOpening(
                todayBoard: todayBoard,
                userName: mentoryiOS.userName ?? "당신"
            )

            RecordInvitationSection(todayBoard: todayBoard)

            CompanionNoteSection(todayBoard: todayBoard)

            SuggestionSection(todayBoard: todayBoard)
        }
        .task {
            await todayBoard.fetchUserRecordCount()

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
        .fullScreenCover(item: $todayBoard.recordFormSelection) { recordForm in
            RecordContainerView(recordForm: recordForm)
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
private struct TodayOpening: View {
    @ObservedObject var todayBoard: TodayBoard
    let userName: String

    var body: some View {
        VStack(alignment: .leading, spacing: MentorySpacing.large) {
            MentoryInfoChip(text: todayLabel, systemImage: "sun.max")

            VStack(alignment: .leading, spacing: 10) {
                Text("오늘 마음은 어땠나요?")
                    .mentoryTitle()
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(summaryCopy)
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var todayLabel: String {
        todayBoard.currentDate.formatted()
    }

    private var summaryCopy: String {
        guard let recordCount = todayBoard.recordCount else {
            return "잠시 숨을 고르고, 지금 가장 오래 남아 있는 장면부터 적어보세요."
        }

        if recordCount == 0 {
            return "첫 기록은 길지 않아도 괜찮아요. 지금 떠오르는 마음 한 줄이면 충분해요."
        }

        return "\(userName)님이 남긴 \(recordCount)개의 기록이 있어요. 오늘의 마음도 이어서 남겨볼까요?"
    }
}

private struct RecordInvitationSection: View {
    @ObservedObject var todayBoard: TodayBoard
    @State private var showDateSelectionSheet = false

    var body: some View {
        MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(recordCardTitle)
                        .mentoryHeadline()
                        .foregroundStyle(.primary)

                    Text(recordCardDescription)
                        .mentorySupportText()
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if todayBoard.recordForms.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(todayBoard.recordForms) { recordForm in
                                RecordAvailabilityChip(recordForm: recordForm)
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
                    Text(availableRecordCount == 0 ? "열린 날짜 다시 보기" : "지금 기록하기")
                }
                .buttonStyle(MentoryPrimaryButtonStyle())
            }
        }
        .sheet(isPresented: $showDateSelectionSheet) {
            DateSelectionSheet(todayBoard: todayBoard)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var availableRecordCount: Int {
        todayBoard.recordForms.filter { $0.isDisabled == false }.count
    }

    private var recordCardTitle: String {
        switch availableRecordCount {
        case 0:
            return "최근 기록은 모두 남겨두었어요."
        case 1:
            return "지금 열려 있는 기록이 하나 있어요."
        default:
            return "지금 열려 있는 기록이 \(availableRecordCount)개 있어요."
        }
    }

    private var recordCardDescription: String {
        switch availableRecordCount {
        case 0:
            return "오늘, 어제, 그제의 기록을 모두 마쳤어요. 다음 날짜가 열리기 전까지는 지난 흐름을 천천히 돌아볼 수 있어요."
        case 1:
            return "짧게라도 남겨두면 오늘의 분석과 제안이 자연스럽게 이어져요."
        default:
            return "오늘, 어제, 그제 중 마음이 가장 선명한 날부터 골라 적어보세요."
        }
    }
}

private struct RecordAvailabilityChip: View {
    @ObservedObject var recordForm: RecordForm

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(relativeLabel)
                .mentoryCaption()
                .foregroundStyle(.primary)

            Text(recordForm.isDisabled ? "기록 완료" : "지금 적을 수 있어요")
                .mentoryEyebrow()
                .foregroundStyle(recordForm.isDisabled ? .secondary : Color.mentoryAccentPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(recordForm.isDisabled ? Color.mentorySubCard.opacity(0.65) : Color.mentorySubCard.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    recordForm.isDisabled ? Color.mentoryBorder.opacity(0.7) : Color.mentoryAccentPrimary.opacity(0.28),
                    lineWidth: 1
                )
        )
    }

    private var relativeLabel: String {
        let relativeDay = recordForm.targetDate.relativeDay(from: .now)
        return relativeDay == .unknown ? recordForm.targetDate.formatted() : relativeDay.rawValue
    }
}

private struct CompanionNoteSection: View {
    @ObservedObject var todayBoard: TodayBoard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MentorySectionHeader(
                eyebrow: "한 문장",
                title: "오늘의 짧은 문장",
                subtitle: "시작 전에 잠깐 읽고 지나가면 충분해요."
            )

            MessageView(mentorMessage: todayBoard.mentorMessage)
        }
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
        MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    MentoryToneMark(character: .warm, size: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("오늘의 문장을 준비하고 있어요")
                            .mentoryHeadline()
                            .foregroundStyle(.primary)

                        Text("조금만 기다리면 오늘의 톤에 맞는 짧은 문장이 도착해요.")
                            .mentorySupportText()
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct SuggestionSection: View {
    @ObservedObject var todayBoard: TodayBoard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MentorySectionHeader(
                eyebrow: "이어서",
                title: "오늘의 작은 제안",
                subtitle: todayBoard.suggestions.isEmpty
                    ? "기록을 마치면 지금 해볼 수 있는 한두 가지 제안이 이어져요."
                    : progressSummary
            )

            if todayBoard.suggestions.isEmpty {
                MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
                    Text("아직 비어 있어요. 오늘의 기록을 남기면 부담 없는 한 걸음이 여기에 정리됩니다.")
                        .mentorySupportText()
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(todayBoard.suggestions, id: \.self.objectID) { suggestion in
                        SuggestionView(suggestion: suggestion)
                    }
                }
            }
        }
        .task {
            await todayBoard.loadSuggestions()
        }
    }

    private var progressSummary: String {
        let completed = todayBoard.suggestions.filter { $0.isDone }.count
        let total = todayBoard.suggestions.count
        return "\(completed)개를 마쳤고, \(max(total - completed, 0))개가 남아 있어요."
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
                    title: "어느 날의 기록을 열까요?",
                    subtitle: "최근 3일 중 열려 있는 날짜를 고를 수 있어요."
                )

                if todayBoard.recordForms.isEmpty {
                    MentoryStatusCard(
                        systemImage: "checkmark.circle.fill",
                        title: "지금은 새로 열려 있는 기록이 없어요",
                        message: "최근 3일의 기록을 모두 마쳤습니다. 다음 날짜가 열리면 다시 이어서 적을 수 있어요.",
                        tint: .green
                    )
                } else {
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
                    Text(relativeLabel)
                        .mentoryHeadline()
                        .foregroundStyle(.primary)

                    Text(recordForm.isDisabled ? "이미 남겨 둔 날이에요" : date.formatted())
                        .mentorySupportText()
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(recordForm.isDisabled ? "완료" : "기록하기")
                    .mentoryEyebrow()
                    .foregroundStyle(recordForm.isDisabled ? .secondary : Color.mentoryAccentPrimary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(recordForm.isDisabled ? Color.mentorySubCard.opacity(0.62) : Color.mentoryCard.opacity(0.98))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        recordForm.isDisabled ? Color.mentoryBorder.opacity(0.7) : Color.mentoryAccentPrimary.opacity(0.22),
                        lineWidth: 1
                    )
            )
            .opacity(recordForm.isDisabled ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
        .task {
            await recordForm.checkDisability()
        }
    }

    private var relativeLabel: String {
        let relativeDay = date.relativeDay(from: .now)
        return relativeDay == .unknown ? date.formatted() : relativeDay.rawValue
    }
}
