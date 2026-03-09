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

    public init(board: StatBoard) {
        self.board = board
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                MentoryBackdrop()

                if isLoading {
                    MentoryStatusCard(
                        systemImage: "chart.bar.xaxis",
                        title: "통계를 불러오는 중입니다",
                        message: "감정 기록과 분석 결과를 정리해 월별 흐름을 준비하고 있어요."
                    )
                    .padding(.horizontal, MentorySpacing.screenHorizontal)
                } else if board.allRecords.isEmpty {
                    MentoryStatusCard(
                        systemImage: "chart.bar",
                        title: "아직 통계가 없어요",
                        message: "기록을 작성하고 분석을 완료하면 달력 위에서 감정 흐름을 확인할 수 있습니다."
                    )
                    .padding(.horizontal, MentorySpacing.screenHorizontal)
                } else {
                    MentoryScrollScreen {
                        StatisticsHero(
                            selectedMonth: selectedMonth,
                            totalCount: board.allRecords.count
                        )

                        MonthHeader(
                            month: selectedMonth,
                            onPrev: { moveMonth(-1) },
                            onNext: { moveMonth(1) },
                            onPickMonth: { setMonth($0) },
                            onToday: { goToday() }
                        )

                        MentorySectionCard(cornerRadius: 30, contentPadding: 18) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("감정 캘린더")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)

                                CalendarGrid(
                                    month: selectedMonth,
                                    selectedDate: selectedDate,
                                    recordForDay: { record(for: $0) },
                                    onSelect: { selectDate($0) }
                                )
                            }
                        }

                        if let selected = selectedDate,
                           let record = record(for: selected) {
                            SelectedDayCard(day: selected, record: record)
                        } else if let selected = selectedDate {
                            MentorySectionCard(cornerRadius: 28, contentPadding: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(selected.formatted(date: .long, time: .omitted))
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.primary)

                                    Text("이 날짜에는 아직 분석 결과가 없습니다.")
                                        .mentorySupportText()
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
            .navigationTitle("통계")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            isLoading = true
            await board.loadRecords()
            isLoading = false
        }
    }

    private func moveMonth(_ value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
        }
    }

    private func setMonth(_ date: Date) {
        selectedMonth = date
    }

    private func goToday() {
        selectedMonth = Date()
        selectedDate = Date()
    }

    private func selectDate(_ date: Date) {
        selectedDate = date
    }

    private func record(for date: Date) -> RecordSnapshot? {
        board.allRecords.first {
            Calendar.current.isDate($0.recordDate.rawValue, inSameDayAs: date)
        }
    }
}

private struct StatisticsHero: View {
    let selectedMonth: Date
    let totalCount: Int

    var body: some View {
        MentorySectionCard(cornerRadius: 34, contentPadding: 24) {
            VStack(alignment: .leading, spacing: 18) {
                MentoryInfoChip(text: "통계", systemImage: "chart.xyaxis.line")

                Text("월별 기록 흐름을 확인하세요")
                    .mentoryTitle()
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("기록한 날짜와 감정 리포트를 함께 보면서 어떤 흐름이 이어졌는지 차분하게 확인할 수 있습니다.")
                    .mentorySupportText()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    MentoryMetricPill(title: "선택 월", value: monthLabel)
                    MentoryMetricPill(title: "누적 기록", value: "\(totalCount)개")
                }
            }
        }
    }

    private var monthLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: selectedMonth)
    }
}

private struct MonthHeader: View {
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
        formatter.dateFormat = "yyyy. M."
        return formatter
    }

    var body: some View {
        MentorySectionCard(cornerRadius: 28, contentPadding: 16) {
            HStack(spacing: 12) {
                Button(action: onPrev) {
                    Image(systemName: "chevron.left")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(MentoryIconButtonStyle())

                Button {
                    let components = calendar.dateComponents([.year, .month], from: month)
                    tempYear = components.year ?? calendar.component(.year, from: Date())
                    tempMonth = components.month ?? calendar.component(.month, from: Date())
                    isShowingMonthPicker = true
                } label: {
                    HStack(spacing: 8) {
                        Text(monthFormatter.string(from: month))
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .buttonStyle(MentorySecondaryButtonStyle())

                Spacer()

                Button("오늘") {
                    onToday()
                }
                .buttonStyle(MentorySecondaryButtonStyle(isEnabled: !isCurrentMonth))
                .disabled(isCurrentMonth)

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(MentoryIconButtonStyle())
            }
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
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
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
        VStack(spacing: 10) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonthGrid(month), id: \.self) { day in
                    DayCell(
                        day: day,
                        isCurrentMonth: calendar.isDate(day, equalTo: month, toGranularity: .month),
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
    let isSelected: Bool
    let record: RecordSnapshot?
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: day))")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(isCurrentMonth ? Color.primary : Color.secondary.opacity(0.5))

                if let record {
                    Text(record.emotion.emoji)
                        .font(.system(size: 18))
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 18, height: 18)
                }
            }
            .frame(height: 56)
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
                    ? Color.mentoryAccentPrimary.opacity(0.14)
                    : record != nil ? Color.mentorySubCard.opacity(0.72) : Color.clear
            )
    }

    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(
                isSelected
                    ? Color.mentoryAccentPrimary.opacity(0.38)
                    : Color.clear,
                lineWidth: 1
            )
    }
}

private struct SelectedDayCard: View {
    let day: Date
    let record: RecordSnapshot

    var body: some View {
        MentorySectionCard(cornerRadius: 30, contentPadding: 22) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.formatted(date: .long, time: .omitted))
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("해당 날짜의 감정 리포트")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(record.emotion.emoji)
                        .font(.system(size: 42))
                }

                Text(record.analyzedResult)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
