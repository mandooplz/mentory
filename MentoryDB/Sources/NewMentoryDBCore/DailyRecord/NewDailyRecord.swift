//
//  NewDailyRecord.swift
//  MentoryDB
//
//  Created by 김민우 on 3/4/26.
//
import Foundation
import OSLog
import SwiftData
import Values


// MARK: - Object
public actor NewDailyRecord: Sendable {
    // MARK: Core
    init(id: UUID) {
        self.id = id
    }

    nonisolated public let id: UUID

    nonisolated private let logger = Logger(
        subsystem: "MentoryDB.NewMentoryDBCore",
        category: "DailyRecord"
    )

    // MARK: Helpers
    private func makeContext() throws -> ModelContext {
        try NewMentoryDBModel.Config.default.makeContext()
    }

    private func descriptor(for id: UUID) -> FetchDescriptor<NewDailyRecordModel> {
        FetchDescriptor<NewDailyRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
    }

    private func fetchRecord(in context: ModelContext) throws -> NewDailyRecordModel {
        guard let record = try context.fetch(descriptor(for: id)).first else {
            throw NewMentoryDBError.recordNotFound
        }

        return record
    }

    // MARK: Query
    public func getSuggestions() -> [SuggestionData] {
        do {
            let context = try makeContext()
            let record = try fetchRecord(in: context)

            return record.suggestions.map { $0.toData() }
        } catch {
            logger.error("getSuggestions 실패: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }
}
