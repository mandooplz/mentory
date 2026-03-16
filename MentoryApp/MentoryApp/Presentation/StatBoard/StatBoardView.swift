//
//  StatBoardView.swift
//  Mentory
//
//  Created by SJS on 12/17/25.
//

import MentoryCore
import SwiftUI
import Values

public struct StatBoardView: View {
    @ObservedObject var board: StatBoard

    @State private var selectedMonth: Date = Date()
    @State private var selectedDate: Date? = Date()
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedEmotion: Emotion? = nil

    public init(board: StatBoard) {
        self.board = board
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                MentoryBackdrop()

                if isLoading {
                    MentoryStatusCard(
                        systemImage: "calendar",
                        title: "기록을 모아보고 있어요",
                        message: "조금만 기다리면 지난 마음의 흐름을 다시 볼 수 있어요."
                    )
                    .padding(.horizontal, MentorySpacing.screenHorizontal)
                } else {
                    MentoryScrollScreen(spacing: 18, topPadding: 18, bottomPadding: 32) {
                        ArchiveHeader()

                        ArchiveCalendarSection(
                            month: selectedMonth,
                            selectedDate: selectedDate,
                            monthlyRecordCount: monthRecords.count,
                            dominantEmotionSummary: dominantEmotionSummary,
                            selectedSummary: selectedSummary,
                            recordForDay: { monthRecord(for: $0) },
                            onPrev: { moveMonth(-1) },
                            onNext: { moveMonth(1) },
                            onPickMonth: { setMonth($0) },
                            onToday: { goToday() },
                            onSelectDate: { selectDate($0) }
                        )

                        if board.allRecords.isEmpty {
                            ArchiveEmptyStateCard()
                        } else {
                            ArchiveSearchBar(text: $searchText)

                            ArchiveEmotionFilterChips(
                                selectedEmotion: $selectedEmotion
                            )

                            if let selected = selectedDate,
                               let record = monthRecord(for: selected) {
                                SelectedDayCard(day: selected, record: record)
                            } else if let selected = selectedDate {
                                MentorySectionCard(cornerRadius: 22, contentPadding: 18) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(selected.formatted(date: .long, time: .omitted))
                                            .mentoryHeadline()
                                            .foregroundStyle(.primary)

                                        Text("이 날짜에는 아직 남아 있는 기록이 없어요.")
                                            .mentorySupportText()
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            TimelineSection(
                                records: visibleRecords,
                                selectedDate: $selectedDate
                            )
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            isLoading = true
            await board.loadRecords()
            updateSelection(for: selectedMonth)
            isLoading = false
        }
    }

    private var monthRecords: [RecordSnapshot] {
        board.allRecords
            .filter { Calendar.current.isDate($0.recordDate.rawValue, equalTo: selectedMonth, toGranularity: .month) }
            .sorted { $0.recordDate.rawValue > $1.recordDate.rawValue }
    }

    private var visibleRecords: [RecordSnapshot] {
        monthRecords
            .filter { record in
                selectedEmotion.map { record.emotion == $0 } ?? true
            }
            .filter { record in
                guard searchText.isEmpty == false else {
                    return true
                }

                return record.analyzedResult.localizedCaseInsensitiveContains(searchText)
            }
    }

    private var selectedSummary: String {
        guard let selectedDate else {
            return "날짜 선택"
        }

        let dayLabel = "\(Calendar.current.component(.day, from: selectedDate))"

        if let record = monthRecord(for: selectedDate) {
            return "\(dayLabel)일 \(record.emotion.emoji)"
        }

        return "\(dayLabel)일"
    }

    private var dominantEmotionSummary: String {
        guard let dominantEmotion = Dictionary(grouping: monthRecords, by: \.emotion)
            .max(by: { $0.value.count < $1.value.count })?.key else {
            return "아직 기록 없음"
        }

        return "\(dominantEmotion.emoji) \(dominantEmotion.archiveLabel)"
    }

    private func moveMonth(_ value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
            updateSelection(for: newDate)
        }
    }

    private func setMonth(_ date: Date) {
        selectedMonth = date
        updateSelection(for: date)
    }

    private func goToday() {
        selectedMonth = Date()
        updateSelection(for: Date(), preferToday: true)
    }

    private func selectDate(_ date: Date) {
        selectedDate = date
    }

    private func monthRecord(for date: Date) -> RecordSnapshot? {
        monthRecords.first {
            Calendar.current.isDate($0.recordDate.rawValue, inSameDayAs: date)
        }
    }

    private func updateSelection(for month: Date, preferToday: Bool = false) {
        let calendar = Calendar.current

        if preferToday,
           calendar.isDate(month, equalTo: Date(), toGranularity: .month) {
            selectedDate = Date()
            return
        }

        if let latestRecord = board.allRecords
            .filter({ calendar.isDate($0.recordDate.rawValue, equalTo: month, toGranularity: .month) })
            .max(by: { $0.recordDate.rawValue < $1.recordDate.rawValue }) {
            selectedDate = latestRecord.recordDate.rawValue
            return
        }

        selectedDate = calendar.date(
            from: calendar.dateComponents([.year, .month], from: month)
        )
    }
}

private struct ArchiveHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("아카이브")
                .mentoryTitle()
                .foregroundStyle(.primary)

            Text("날짜를 눌러 지난 마음의 흐름을 조용히 다시 읽어보세요.")
                .mentoryCaption()
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ArchiveCalendarSection: View {
    let month: Date
    let selectedDate: Date?
    let monthlyRecordCount: Int
    let dominantEmotionSummary: String
    let selectedSummary: String
    let recordForDay: (Date) -> RecordSnapshot?
    let onPrev: () -> Void
    let onNext: () -> Void
    let onPickMonth: (Date) -> Void
    let onToday: () -> Void
    let onSelectDate: (Date) -> Void

    var body: some View {
        MentorySectionCard(cornerRadius: 30, contentPadding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                ArchiveMonthNavigation(
                    month: month,
                    onPrev: onPrev,
                    onNext: onNext,
                    onPickMonth: onPickMonth,
                    onToday: onToday
                )

                CalendarGrid(
                    month: month,
                    selectedDate: selectedDate,
                    recordForDay: recordForDay,
                    onSelect: onSelectDate
                )
            }
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: month)
    }
}

private struct ArchiveCompactMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .mentoryEyebrow()
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.mentorySubCard.opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.mentoryBorder.opacity(0.72), lineWidth: 1)
        )
    }
}

private struct ArchiveSearchBar: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("검색")
                .mentoryEyebrow()
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("기록 속 문장을 찾아보세요", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                if text.isEmpty == false {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 46)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.mentoryCard.opacity(0.94))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.mentoryBorder.opacity(0.82), lineWidth: 1)
            )
        }
    }
}

private struct ArchiveEmptyStateCard: View {
    var body: some View {
        MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                MentoryInfoChip(text: "아직 비어 있어요", systemImage: "book.closed")

                Text("첫 기록을 남기면 이 달력 위에 감정의 흐름이 차분히 쌓입니다.")
                    .mentoryHeadline()
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("지금은 날짜 탐색 중심의 아카이브 구조만 먼저 보여주고 있어요.")
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ArchiveEmotionFilterChips: View {
    @Binding var selectedEmotion: Emotion?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("감정 필터")
                .mentoryEyebrow()
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "전체",
                        isSelected: selectedEmotion == nil
                    ) {
                        selectedEmotion = nil
                    }

                    ForEach(Emotion.allCases, id: \.self) { emotion in
                        FilterChip(
                            title: "\(emotion.emoji) \(emotion.archiveLabel)",
                            isSelected: selectedEmotion == emotion
                        ) {
                            selectedEmotion = emotion
                        }
                    }
                }
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .mentoryEyebrow()
                .foregroundStyle(isSelected ? Color.mentoryAccentPrimary : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.mentoryAccentPrimary.opacity(0.12) : Color.mentorySubCard.opacity(0.7))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(isSelected ? Color.mentoryAccentPrimary.opacity(0.26) : Color.mentoryBorder.opacity(0.7), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private extension Emotion {
    var archiveLabel: String {
        switch self {
        case .veryUnpleasant: return "무거움"
        case .unPleasant: return "불편함"
        case .slightlyUnpleasant: return "걸림"
        case .neutral: return "담담함"
        case .slightlyPleasant: return "온기"
        case .pleasant: return "좋은 흐름"
        case .veryPleasant: return "활기"
        }
    }

    var calendarTint: Color {
        switch self {
        case .veryUnpleasant: return Color.red.opacity(0.78)
        case .unPleasant: return Color.orange.opacity(0.78)
        case .slightlyUnpleasant: return Color.yellow.opacity(0.78)
        case .neutral: return Color.gray.opacity(0.72)
        case .slightlyPleasant: return Color.mint.opacity(0.76)
        case .pleasant: return Color.blue.opacity(0.74)
        case .veryPleasant: return Color.pink.opacity(0.72)
        }
    }
}

private struct ArchiveMonthNavigation: View {
    let month: Date
    let onPrev: () -> Void
    let onNext: () -> Void
    let onPickMonth: (Date) -> Void
    let onToday: () -> Void

    @State private var isShowingMonthPicker = false
    @State private var tempYear: Int = 0
    @State private var tempMonth: Int = 0

    private let calendar = Calendar.current

    private var isCurrentMonth: Bool {
        Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month)
    }

    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 0) {
                navigationIcon(systemName: "chevron.left", action: onPrev)

                Rectangle()
                    .fill(Color.mentoryBorder.opacity(0.52))
                    .frame(width: 1, height: 20)

                Button {
                    let components = calendar.dateComponents([.year, .month], from: month)
                    tempYear = components.year ?? calendar.component(.year, from: Date())
                    tempMonth = components.month ?? calendar.component(.month, from: Date())
                    isShowingMonthPicker = true
                } label: {
                    HStack(spacing: 8) {
                        Text(monthFormatter.string(from: month))
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)

                        Image(systemName: "chevron.down")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 46)
                }
                .buttonStyle(.plain)

                Rectangle()
                    .fill(Color.mentoryBorder.opacity(0.52))
                    .frame(width: 1, height: 20)

                navigationIcon(systemName: "chevron.right", action: onNext)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.mentoryCard.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.mentoryBorder.opacity(0.82), lineWidth: 1)
            )

            Button("오늘", action: onToday)
                .buttonStyle(MentorySecondaryButtonStyle(isEnabled: !isCurrentMonth))
                .disabled(isCurrentMonth)
                .frame(width: 72)
        }
        .sheet(isPresented: $isShowingMonthPicker) {
            MonthPickerSheet(
                tempYear: $tempYear,
                tempMonth: $tempMonth,
                onCancel: { isShowingMonthPicker = false },
                onDone: {
                    if let date = calendar.date(
                        from: DateComponents(year: tempYear, month: tempMonth, day: 1)
                    ) {
                        onPickMonth(date)
                    }
                    isShowingMonthPicker = false
                }
            )
            .presentationDetents([.height(300)])
        }
    }

    private func navigationIcon(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 42, height: 46)
        }
        .buttonStyle(.plain)
    }
}

private struct MonthPickerSheet: View {
    @Binding var tempYear: Int
    @Binding var tempMonth: Int
    let onCancel: () -> Void
    let onDone: () -> Void

    @State private var yearCenter: Int = 0
    @State private var yearIndex: Int = 0
    @State private var monthIndex: Int = 0

    private let yearSpan = 200
    private let monthItems: [Int] = Array(1...12) + Array(1...12) + Array(1...12)

    private var yearItems: [Int] {
        let half = yearSpan / 2
        return Array((yearCenter - half)...(yearCenter + half))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MentoryBackdrop()

                VStack(spacing: 12) {
                    HStack {
                        Button("취소", action: onCancel)
                        Spacer()
                        Button("선택", action: onDone)
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 20)

                    HStack {
                        Picker("년도", selection: $yearIndex) {
                            ForEach(Array(yearItems.enumerated()), id: \.offset) { index, year in
                                Text(verbatim: "\(year)년").tag(index)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("월", selection: $monthIndex) {
                            ForEach(Array(monthItems.enumerated()), id: \.offset) { index, month in
                                Text("\(month)월").tag(index)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
            }
        }
        .onAppear {
            yearCenter = tempYear
            yearIndex = yearSpan / 2
            monthIndex = 12 + (tempMonth - 1)
        }
        .onChange(of: yearIndex) { _, newValue in
            guard yearItems.indices.contains(newValue) else { return }
            tempYear = yearItems[newValue]

            if newValue < 20 || newValue > yearItems.count - 21 {
                yearCenter = tempYear
                DispatchQueue.main.async {
                    yearIndex = yearSpan / 2
                }
            }
        }
        .onChange(of: monthIndex) { _, newValue in
            guard monthItems.indices.contains(newValue) else { return }
            tempMonth = monthItems[newValue]

            if newValue < 6 {
                monthIndex += 12
            } else if newValue > monthItems.count - 7 {
                monthIndex -= 12
            }
        }
    }
}

private struct CalendarGrid: View {
    let month: Date
    let selectedDate: Date?
    let recordForDay: (Date) -> RecordSnapshot?
    let onSelect: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .mentoryEyebrow()
                        .foregroundStyle(.secondary)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(daysInMonthGrid(month), id: \.self) { day in
                    DayCell(
                        day: day,
                        isCurrentMonth: calendar.isDate(day, equalTo: month, toGranularity: .month),
                        isToday: calendar.isDateInToday(day),
                        isSelected: selectedDate.map {
                            calendar.isDate($0, inSameDayAs: day)
                        } ?? false,
                        record: recordForDay(day),
                        onTap: { onSelect(day) }
                    )
                }
            }
        }
    }

    private func daysInMonthGrid(_ month: Date) -> [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)

        var days: [Date] = []

        let leading = firstWeekday - 1
        if leading > 0 {
            for index in stride(from: leading, to: 0, by: -1) {
                days.append(calendar.date(byAdding: .day, value: -index, to: startOfMonth)!)
            }
        }

        for day in range {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!)
        }

        while days.count % 7 != 0 {
            days.append(calendar.date(byAdding: .day, value: 1, to: days.last!)!)
        }

        return days
    }
}

private struct DayCell: View {
    let day: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let record: RecordSnapshot?
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                Text("\(calendar.component(.day, from: day))")
                    .font(.system(.subheadline, design: .rounded, weight: record == nil ? .medium : .semibold))
                    .foregroundStyle(isCurrentMonth ? Color.primary : Color.secondary.opacity(0.42))

                if let record {
                    Circle()
                        .fill(record.emotion.calendarTint)
                        .frame(width: 6, height: 6)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.52), lineWidth: 1)
                        )
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background(backgroundShape)
            .overlay(backgroundOverlay)
        }
        .buttonStyle(.plain)
    }

    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                isSelected
                    ? Color.mentoryAccentPrimary.opacity(0.16)
                    : record.map { $0.emotion.calendarTint.opacity(isCurrentMonth ? 0.14 : 0.06) } ?? Color.clear
            )
    }

    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(
                isSelected
                    ? Color.mentoryAccentPrimary.opacity(0.34)
                    : isToday ? Color.mentoryBorder.opacity(0.5) : Color.clear,
                lineWidth: 1
            )
    }
}

private struct SelectedDayCard: View {
    let day: Date
    let record: RecordSnapshot

    var body: some View {
        MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        MentoryInfoChip(text: "선택한 기록", systemImage: "sparkles")

                        Text(day.formatted(date: .long, time: .omitted))
                            .mentoryHeadline()
                            .foregroundStyle(.primary)

                        HStack(spacing: 8) {
                            Circle()
                                .fill(record.emotion.calendarTint)
                                .frame(width: 8, height: 8)

                            Text(record.emotion.archiveLabel)
                                .mentoryEyebrow()
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(record.emotion.calendarTint.opacity(0.14))
                            .frame(width: 44, height: 44)

                        Text(record.emotion.emoji)
                            .font(.system(.title3, design: .rounded, weight: .regular))
                    }
                }

                Text(record.analyzedResult)
                    .mentorySupportText()
                    .foregroundStyle(.primary.opacity(0.86))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct TimelineSection: View {
    let records: [RecordSnapshot]
    @Binding var selectedDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MentorySectionHeader(
                eyebrow: "기록",
                title: "이 달의 기록",
                subtitle: records.isEmpty ? "조건에 맞는 기록이 없어요." : "캘린더 아래에서 기록을 다시 읽어보세요."
            )

            if records.isEmpty {
                MentorySectionCard(cornerRadius: 24, contentPadding: 18) {
                    Text("검색어나 감정 필터를 조금 느슨하게 바꾸면 더 많은 기록이 보여요.")
                        .mentorySupportText()
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(records, id: \.recordID) { record in
                        let isSelected = selectedDate.map {
                            Calendar.current.isDate($0, inSameDayAs: record.recordDate.rawValue)
                        } ?? false

                        Button {
                            selectedDate = record.recordDate.rawValue
                        } label: {
                            HStack(alignment: .top, spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(record.emotion.calendarTint.opacity(0.14))
                                        .frame(width: 36, height: 36)

                                    Text(record.emotion.emoji)
                                        .font(.system(.body, design: .rounded, weight: .regular))
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text(record.recordDate.rawValue.formatted(date: .abbreviated, time: .omitted))
                                            .mentoryEyebrow()
                                            .foregroundStyle(.secondary)

                                        Text(record.emotion.archiveLabel)
                                            .mentoryCaption()
                                            .foregroundStyle(record.emotion.calendarTint)
                                    }

                                    Text(record.analyzedResult)
                                        .mentorySupportText()
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        isSelected
                                            ? Color.mentoryAccentPrimary.opacity(0.09)
                                            : Color.mentoryCard.opacity(0.96)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        isSelected
                                            ? Color.mentoryAccentPrimary.opacity(0.24)
                                            : Color.mentoryBorder.opacity(0.78),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}


// MARK: Preview
fileprivate struct StatBoardPreview: View {
    @StateObject var mentoryiOS = Mentory()

    var body: some View {
        if let statBoard = mentoryiOS.statBoard {
            StatBoardView(board: statBoard)
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
    StatBoardPreview()
}
