//
//  StatisticsView.swift
//  Mentory
//
//  Created by JAY on 12/03/25.
//

import SwiftUI
import Charts
import Values


// MARK: View
struct StatisticsView: View {
    // MARK: view state
    @State private var displayMode: DisplayMode = .monthly
    @State private var referenceMonth = Date()
    @State private var monthlyFocus = ""
    @State private var timeLog = ""
    @State private var moodFlowNote = ""

    private let calendarSlots = MoodSlot.sampleAugust
    private let chartEntries = MoodChartEntry.sample

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: referenceMonth)
    }

    // MARK: body
    var body: some View {
        ZStack {
            MentoryColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header
                    calendarCard
                    summaryRingCard
                    summaryTextCard
                    inputCard(title: "월 단위 감정 횟수", text: $monthlyFocus, placeholder: "예: 감정을 기록할 때 느낀 점, 오늘의 포인트 등 자유롭게 적어보세요.")
                    inputCard(title: "시간 통계", text: $timeLog, placeholder: "광고1편을 보는 시간동안 작성했어요. 주로 밤에 작성해요")
                    chartCard
                    inputCard(title: "감정 변화를 행동 그래프와 함께 살펴봐요", text: $moodFlowNote, placeholder: "")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
    }
}


// MARK: subviews
private extension StatisticsView {
    var header: some View {
        HStack(alignment: .center) {
            Text("통계")
                .font(.system(size: 30, weight: .bold))
            Spacer()
//            Picker("기간", selection: $displayMode) {
//                ForEach(DisplayMode.allCases, id: \.self) { mode in
//                    Text(mode.rawValue)
//                        .tag(mode)
//                }
//            }
//            .pickerStyle(.segmented)
//            .frame(width: 160)
        }
    }

    var calendarCard: some View {
        OutlinedSection {
            VStack(spacing: 14) {
                HStack {
                    Button(action: { shiftMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Spacer()
                    Text(monthTitle)
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Button(action: { shiftMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .foregroundStyle(.primary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(calendarSlots) { slot in
                        MoodDayCell(slot: slot)
                    }
                }
            }
        }
    }

    var summaryRingCard: some View {
        OutlinedSection {
            VStack(spacing: 16) {
//                Text("12월의 감정")
//                    .font(.system(size: 16, weight: .semibold))
//                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                ZStack {
                    Circle()
                        .stroke(MentoryColor.border.opacity(0.5), lineWidth: 25)
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .trim(from: 0, to: 0.68)
                        .stroke(MentoryColor.accentPrimary, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 180, height: 180)
                    
                    VStack(spacing: 8) {
                        Image("cool")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                        Text("5번 기록")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
            Spacer()
            }
        }
    }

    var summaryTextCard: some View {
        OutlinedSection {
            VStack(alignment: .leading, spacing: 10) {
                Text("12월 깝십의 감정은?")
                    .font(.system(size: 16, weight: .semibold))
                Text("생생한 기록을 남기며 느낀 감정과 생각을 돌아보고, 패턴을 발견해보세요. \n\n조금 더 구체적으로 적을수록 다음 달의 목표를 세우기 쉬워집니다.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MentoryColor.accentPrimary.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(MentoryColor.border.opacity(0.6), lineWidth: 1)
                    )
            }
        }
    }

    func inputCard(title: String, text: Binding<String>, placeholder: String) -> some View {
        OutlinedSection {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                ZStack(alignment: .topLeading) {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.secondary)
                            .padding(EdgeInsets(top: 12, leading: 10, bottom: 0, trailing: 0))
                    }
                    TextEditor(text: text)
                        .frame(minHeight: 90, maxHeight: 130)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(MentoryColor.border.opacity(0.6), lineWidth: 1)
                        )
                }
            }
        }
    }

    var chartCard: some View {
        OutlinedSection {
            VStack(alignment: .leading, spacing: 12) {
                Text("감정과 행동추천")
                    .font(.system(size: 16, weight: .semibold))
                Chart {
                    ForEach(chartEntries) { entry in
                        BarMark(
                            x: .value("Week", entry.label),
                            y: .value("Minutes", entry.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: entry.gradient),
                                startPoint: .top,
                                endPoint: .bottom)
                        )

                        LineMark(
                            x: .value("Week", entry.label),
                            y: .value("Minutes", entry.value + entry.trendOffset)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.black.opacity(0.65))
                        .lineStyle(.init(lineWidth: 2.5))
                    }
                }
                .frame(height: 220)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
    }
}


// MARK: components
private struct OutlinedSection<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(MentoryColor.accentPrimary.opacity(0.4), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 6)
    }
}

private struct MoodDayCell: View {
    let slot: StatisticsView.MoodSlot

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(slot.isHighlighted ? Color.red : MentoryColor.border.opacity(0.8), lineWidth: 2)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white)
                )

            if let character = slot.character {
                Image(character.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            } else if let day = slot.day {
                Text("\(day)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}


// MARK: model
private extension StatisticsView {
    enum DisplayMode: String, CaseIterable {
        case daily = "일별"
        case monthly = "월별"
    }

    struct MoodSlot: Identifiable {
        let id = UUID()
        let day: Int?
        let character: MentoryCharacter?
        let isHighlighted: Bool

        init(day: Int?, character: MentoryCharacter? = nil, isHighlighted: Bool = false) {
            self.day = day
            self.character = character
            self.isHighlighted = isHighlighted
        }

        static let sampleAugust: [MoodSlot] = [
            .init(day: 1, character: .cool),
            .init(day: 2, character: .warm),
            .init(day: 3),
            .init(day: 4),
            .init(day: 5, character: .cool),
            .init(day: 6),
            .init(day: 7),
            .init(day: 8),
            .init(day: 9),
            .init(day: 10),
            .init(day: 11),
            .init(day: 12),
            .init(day: 13),
            .init(day: 14),
            .init(day: 15, character: .warm),
            .init(day: 16),
            .init(day: 17, character: .cool),
            .init(day: 18, isHighlighted: true),
            .init(day: 19),
            .init(day: 20),
            .init(day: 21),
            .init(day: 22),
            .init(day: 23),
            .init(day: 24),
            .init(day: 25),
            .init(day: 26),
            .init(day: 27),
            .init(day: 28),
            .init(day: 29),
            .init(day: 30),
            .init(day: 31),
            .init(day: nil),
            .init(day: nil),
            .init(day: nil),
            .init(day: nil)
        ]
    }

    struct MoodChartEntry: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let trendOffset: Double

        var gradient: [Color] {
            [
                MentoryColor.accentSecondary.opacity(0.95),
                MentoryColor.accentPrimary.opacity(0.8)
            ]
        }

        static let sample: [MoodChartEntry] = [
            .init(label: "1", value: 16, trendOffset: 6),
            .init(label: "2", value: 10, trendOffset: 8),
            .init(label: "3", value: 18, trendOffset: 4),
            .init(label: "4", value: 14, trendOffset: 10),
            .init(label: "5", value: 22, trendOffset: 3),
            .init(label: "6", value: 12, trendOffset: 12)
        ]
    }

    func shiftMonth(by value: Int) {
        if let updated = Calendar.current.date(byAdding: .month, value: value, to: referenceMonth) {
            referenceMonth = updated
        }
    }
}


// MARK: Preview
#Preview {
    StatisticsView()
        .previewDevice("iPhone 15 Pro")
}
