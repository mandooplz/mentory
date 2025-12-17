//
//  StatisticsBoard.swift
//  Mentory
//
//  Created by SJS on 12/17/25.
//

import Foundation
import Observation
import Values

@Observable
final class StatisticsBoard {

    struct State: Equatable {
        var isLoading: Bool = false
        var records: [RecordData] = []
        var emotionCounts: [Emotion: Int] = [:]
        var errorMessage: String? = nil
    }

    private(set) var state = State()
    private let mentoryDB: MentoryDBAdapter

    init(mentoryDB: MentoryDBAdapter) {
        self.mentoryDB = mentoryDB
    }

    func load() {
        state.isLoading = true
        state.errorMessage = nil

        Task {
            do {
                let records = try await mentoryDB.getRecords()

                let counts = Dictionary(grouping: records, by: { $0.emotion })
                    .mapValues { $0.count }

                await MainActor.run {
                    self.state.records = records
                    self.state.emotionCounts = counts
                    self.state.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.state.records = []
                    self.state.emotionCounts = [:]
                    self.state.isLoading = false
                    self.state.errorMessage = "통계 데이터를 불러오지 못했습니다."
                }
            }
        }
    }
}
