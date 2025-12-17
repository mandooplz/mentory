//
//  StatisticsBoardView.swift
//  Mentory
//
//  Created by SJS on 12/17/25.
//

import SwiftUI
import Values

struct StatisticsBoardView: View {

    @State private var board: StatisticsBoard

    init(board: StatisticsBoard) {
        _board = State(initialValue: board)
    }

    var body: some View {
        NavigationStack {
            Group {
                if board.state.isLoading {
                    ProgressView()
                } else if let message = board.state.errorMessage {
                    ContentUnavailableView(
                        "불러오기 실패",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                } else if board.state.records.isEmpty {
                    ContentUnavailableView(
                        "분석 결과가 없어요",
                        systemImage: "chart.bar",
                        description: Text("기록을 작성하고 분석을 완료하면 통계가 표시됩니다.")
                    )
                } else {
                    List {
                        Section("감정 분포") {
                            EmotionCountList(counts: board.state.emotionCounts)
                        }

                        Section("기록 히스토리") {
                            ForEach(board.state.records, id: \.id) { record in
                                RecordRow(record: record)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("통계")
        }
        .onAppear { board.load() }
    }
}

private struct EmotionCountList: View {
    let counts: [Emotion: Int]

    var body: some View {
        let sorted = counts.keys.sorted { counts[$0, default: 0] > counts[$1, default: 0] }

        ForEach(sorted, id: \.self) { emotion in
            HStack {
                Text(emotion.rawValue)
                Spacer()
                Text("\(counts[emotion, default: 0])")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct RecordRow: View {
    let record: RecordData

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.emotion.rawValue)
                    .font(.headline)

                Spacer()

                Text(record.recordDate.rawValue.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(record.analyzedResult)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
