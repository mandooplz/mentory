//
//  StatisticsBoardExt.swift
//  Mentory
//
//  Created by 김민우 on 2/25/26.
//
import Foundation
import Combine
import Values
import MentoryDBAdapter


// MARK: object
@MainActor
public final class StatisticsBoardExt: ObservableObject {
    // MARK: core
    private let mentoryDB: any MentoryDBInterface
    
    public init(mentoryDB: any MentoryDBInterface) {
        self.mentoryDB = mentoryDB
    }
    
    
    // MARK: state
    private let calendar = Calendar.current
    
    @Published public var isLoading: Bool = false
    @Published public var allRecords: [RecordData] = []
    
    @Published public var selectedMonth: Date = Date() { didSet { if oldValue != selectedMonth { selectedDate = nil } } }
    @Published public var selectedDate: Date? = nil
    @Published public var errorMesage: String? = nil
    
    
    // MARK: action
    // MentoryDB에서 기록들을 load
    public func loadRecords() {
        // capture
        isLoading = true
        errorMesage = nil

        // process
        Task {
            do {
                let records = try await mentoryDB.getRecords()
                // mutate
                self.allRecords = records
                self.isLoading = false
            } catch {
                self.errorMesage = error.localizedDescription
                self.isLoading = false
            }
        }
    }


    // MARK: - Calendar derived state
    public struct DayCell: Identifiable, Hashable {
        public let id = UUID()
        public let date: Date?
        public let isWithinMonth: Bool
        public let isToday: Bool
        public let isSelected: Bool
        public let recordCount: Int
    }

    // 월 타이틀 (예: 2026년 2월)
    public var monthTitle: String {
        let df = DateFormatter()
        df.locale = Locale.current
        df.calendar = calendar
        df.dateFormat = "yyyy년 M월"
        return df.string(from: startOfMonth(for: selectedMonth))
    }

    // 요일 헤더 (캘린더의 firstWeekday를 반영)
    public var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1 // 0-based
        return Array(symbols[first...] + symbols[..<first])
    }

    // 선택된 달의 모든 레코드
    public var recordsInSelectedMonth: [RecordData] {
        let start = startOfMonth(for: selectedMonth)
        let end = endOfMonth(for: selectedMonth)
        return allRecords.filter { data in
            let d = data.recordDate.rawValue
            return (d >= start) && (d < end)
        }
    }

    // 선택된 날짜의 레코드
    public var recordsForSelectedDate: [RecordData] {
        guard let selectedDate else { return [] }
        return allRecords.filter { data in
            calendar.isDate(data.recordDate.rawValue, inSameDayAs: selectedDate)
        }
    }

    // 월 그리드(7열)로 표시할 DayCell 목록
    public var monthGrid: [DayCell] {
        let start = startOfMonth(for: selectedMonth)
        let dayCount = daysInMonthCount(for: selectedMonth)

        let leading = leadingEmptyCount(for: start)
        let trailing = trailingEmptyCount(leading: leading, dayCount: dayCount)

        var cells: [DayCell] = []

        // 앞쪽 비우기(이전 달 날짜 표시, withinMonth = false)
        if leading > 0 {
            let prevMonth = calendar.date(byAdding: DateComponents(month: -1), to: selectedMonth) ?? selectedMonth
            let prevStart = startOfMonth(for: prevMonth)
            let prevCount = daysInMonthCount(for: prevMonth)
            let startDay = prevCount - leading + 1
            for day in startDay...prevCount {
                let date = calendar.date(byAdding: .day, value: day - 1, to: prevStart)!
                cells.append(makeCell(for: date, isWithinMonth: false))
            }
        }

        // 현재 달 날짜
        for day in 1...dayCount {
            let date = calendar.date(byAdding: .day, value: day - 1, to: start)!
            cells.append(makeCell(for: date, isWithinMonth: true))
        }

        // 뒤쪽 비우기(다음 달 날짜 표시, withinMonth = false)
        if trailing > 0 {
            let nextMonth = calendar.date(byAdding: DateComponents(month: 1), to: selectedMonth) ?? selectedMonth
            let nextStart = startOfMonth(for: nextMonth)
            for day in 1...trailing {
                let date = calendar.date(byAdding: .day, value: day - 1, to: nextStart)!
                cells.append(makeCell(for: date, isWithinMonth: false))
            }
        }

        return cells
    }

    // 7열로 나눈 주 단위 배열
    public var weeks: [[DayCell]] {
        let grid = monthGrid
        guard grid.isEmpty == false else { return [] }
        var result: [[DayCell]] = []
        var idx = 0
        while idx < grid.count {
            let end = min(idx + 7, grid.count)
            result.append(Array(grid[idx..<end]))
            idx = end
        }
        return result
    }

    // MARK: - Calendar actions
    public func goToPreviousMonth() {
        if let newMonth = calendar.date(byAdding: DateComponents(month: -1), to: selectedMonth) {
            selectedMonth = newMonth
        }
    }

    public func goToNextMonth() {
        if let newMonth = calendar.date(byAdding: DateComponents(month: 1), to: selectedMonth) {
            selectedMonth = newMonth
        }
    }

    public func selectDate(_ date: Date?) {
        selectedDate = date
    }

    // MARK: - Helpers
    private func startOfMonth(for date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    private func endOfMonth(for date: Date) -> Date {
        var comps = DateComponents()
        comps.month = 1
        comps.day = -0
        let start = startOfMonth(for: date)
        // 다음 달 시작
        let nextMonthStart = calendar.date(byAdding: DateComponents(month: 1), to: start) ?? start
        return nextMonthStart
    }

    private func daysInMonthCount(for date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }

    private func leadingEmptyCount(for monthStart: Date) -> Int {
        // monthStart의 weekday 기준으로 firstWeekday에 맞춘 선행 공백 수 계산
        let weekday = calendar.component(.weekday, from: monthStart) // 1...7
        // 0-based 보정
        let first = calendar.firstWeekday
        return (weekday - first + 7) % 7
    }

    private func trailingEmptyCount(leading: Int, dayCount: Int) -> Int {
        let total = leading + dayCount
        let remainder = total % 7
        return remainder == 0 ? 0 : (7 - remainder)
    }

    private func makeCell(for date: Date, isWithinMonth: Bool) -> DayCell {
        let isToday = calendar.isDateInToday(date)
        let isSelected = {
            guard let selectedDate else { return false }
            return calendar.isDate(selectedDate, inSameDayAs: date)
        }()
        let count = recordCount(on: date)
        return DayCell(
            date: date,
            isWithinMonth: isWithinMonth,
            isToday: isToday,
            isSelected: isSelected,
            recordCount: count
        )
    }

    private func recordCount(on date: Date) -> Int {
        return allRecords.reduce(0) { partial, data in
            partial + (calendar.isDate(data.recordDate.rawValue, inSameDayAs: date) ? 1 : 0)
        }
    }

    // MARK: core
}
