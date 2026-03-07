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


// MARK: interface
public protocol NewDailyRecordInterface: Actor, Sendable {
    // MARK: state
    var id: UUID { get }
    var suggestions: [SuggestionData] { get }
}


// MARK: object
public actor NewDailyRecord: NewDailyRecordInterface {
    // MARK: Core
    init(id: UUID) {
        self.id = id
    }
    nonisolated public let id: UUID
    nonisolated private let logger = Logger()


    public var suggestions: [SuggestionData] {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.id)

            guard let record = try context.fetch(descriptor).first else {
                throw NewMentoryDBError.recordNotFound
            }

            return record.suggestions.map { $0.toData() }
        } catch {
            logger.error("getSuggestions 실패: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }
}
