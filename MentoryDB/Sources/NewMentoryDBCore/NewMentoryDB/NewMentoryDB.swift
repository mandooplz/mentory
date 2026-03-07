//
//  NewMentoryDBCore.swift
//  MentoryDB
//
//  Created by 김민우 on 3/4/26.
//
import Foundation
import OSLog
import SwiftData
import Values


// MARK: object
public actor NewMentoryDB: Sendable, NewMentoryDBInterface {
    // MARK: core
    private nonisolated let logger = Logger()
    public init(id: UUID) {
        self.id = id
    }


    // MARK: state
    public nonisolated let id: UUID

    public var name: String? {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            return try NewMentoryDBConfig.default.fetchDB(in: context).userName
        } catch {
            logger.error("getName 실패: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    public func setName(_ newValue: String) async {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            try NewMentoryDBConfig.default.updateDB(in: context) { db in
                db.userName = newValue
            }

            logger.debug("이름 저장 완료")
        } catch {
            logger.error("setName 실패: \(error.localizedDescription, privacy: .public)")
        }
    }

    public var character: MentoryCharacter? {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            return try NewMentoryDBConfig.default.fetchDB(in: context).userCharacter
        } catch {
            logger.error("getCharacter 실패: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    public func setCharacter(_ newValue: MentoryCharacter) async {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            try NewMentoryDBConfig.default.updateDB(in: context) { db in
                db.userCharacter = newValue
            }

            logger.debug("캐릭터 저장 완료")
        } catch {
            logger.error("setCharacter 실패: \(error.localizedDescription, privacy: .public)")
        }
    }

    public var mentorMessage: MessageData? {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            guard let createdAt = db.messageCreatedAt,
                  let content = db.messageContent,
                  let character = db.messageCharacter else {
                return nil
            }

            return MessageData(
                createdAt: .init(createdAt),
                content: content,
                characterType: character
            )
        } catch {
            logger.error("getMentorMessage 실패: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    public func setMentorMessage(_ newValue: MessageData) async {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            try NewMentoryDBConfig.default.updateDB(in: context) { db in
                db.messageCreatedAt = newValue.createdAt.rawValue
                db.messageContent = newValue.content
                db.messageCharacter = newValue.characterType
            }

            logger.debug("멘토 메시지 저장 완료")
        } catch {
            logger.error("setMentorMessage 실패: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    public var records: [RecordData] {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            return db.records
                .sorted(by: { $0.recordDate > $1.recordDate })
                .map { $0.toRecordData() }
        } catch {
            logger.error("getRecords 실패: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }
    public var recordCount: Int {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            return try NewMentoryDBConfig.default.fetchDB(in: context).records.count
        } catch {
            logger.error("getRecordCount 실패: \(error.localizedDescription, privacy: .public)")
            return 0
        }
    }
    public var recentRecord: NewDailyRecord? {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            guard let latest = db.records.max(by: { $0.recordDate < $1.recordDate }) else {
                return nil
            }

            return NewDailyRecord(id: latest.id)
        } catch {
            logger.error("getRecentRecord 실패: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    public func getRecord(ticketId: UUID) -> NewDailyRecord? {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            guard let target = db.records.first(where: { $0.ticketId == ticketId }) else {
                return nil
            }

            return NewDailyRecord(id: target.id)
        } catch {
            logger.error("getRecord 실패: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    public func isSameDayRecordExist(for date: MentoryDate) -> Bool {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            return db.records.contains { record in
                MentoryDate(record.recordDate).isSameDate(as: date)
            }
        } catch {
            logger.error("isSameDayRecordExist 실패: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }
    
    public var completedSuggestionCount: Int {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            return db.records.reduce(0) { total, record in
                total + record.suggestions.filter { $0.status }.count
            }
        } catch {
            logger.error("getCompletedSuggestionsCount 실패: \(error.localizedDescription, privacy: .public)")
            return 0
        }
    }
    public func updateSuggestionStatus(targetId: UUID, isDone: Bool) {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            for record in db.records {
                if let suggestion = record.suggestions.first(where: { $0.target == targetId }) {
                    suggestion.status = isDone
                    try context.save()
                    logger.debug("Suggestion 상태 업데이트 완료")
                    return
                }
            }

            logger.warning("대상 Suggestion 미존재: \(targetId.uuidString, privacy: .public)")
        } catch {
            logger.error("updateSuggestionStatus 실패: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func insertTicket(_ recordData: RecordData) {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            let ticketId = recordData.id
            guard db.records.contains(where: { $0.ticketId == ticketId }) == false else {
                logger.debug("insertTicket 중복 스킵(records): \(ticketId.uuidString, privacy: .public)")
                return
            }

            guard db.recordCreationQueue.contains(where: { $0.id == ticketId }) == false else {
                logger.debug("insertTicket 중복 스킵(queue): \(ticketId.uuidString, privacy: .public)")
                return
            }

            db.recordCreationQueue.append(NewRecordTicket(data: recordData))
            try context.save()
            logger.debug("insertTicket 완료")
        } catch {
            logger.error("insertTicket 실패: \(error.localizedDescription, privacy: .public)")
        }
    }
    public func insertSuggestions(ticketId: UUID, suggestions: [SuggestionData]) async {
        guard suggestions.isEmpty == false else {
            return
        }

        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            guard let record = db.records.first(where: { $0.ticketId == ticketId }) else {
                throw NewMentoryDBError.recordNotFound
            }

            var existingIDs = Set(record.suggestions.map { $0.id })
            var insertedCount = 0

            for suggestion in suggestions {
                guard existingIDs.insert(suggestion.id).inserted else {
                    continue
                }

                record.suggestions.append(NewDailySuggestionModel(data: suggestion))
                insertedCount += 1
            }

            if insertedCount > 0 {
                try context.save()
            }

            logger.debug(
                "insertSuggestions 완료 (inserted: \(insertedCount), skipped: \(suggestions.count - insertedCount))"
            )
        } catch {
            logger.error("insertSuggestions 실패: \(error.localizedDescription, privacy: .public)")
        }
    }

    
    // MARK: action
    public func createDailyRecords() async {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            guard db.recordCreationQueue.isEmpty == false else {
                logger.debug("createDailyRecords 스킵: queue empty")
                return
            }

            let queuedTickets = db.recordCreationQueue
            var existingTicketIDs = Set(db.records.map { $0.ticketId })
            var batchTicketIDs: Set<UUID> = []

            var createdCount = 0
            var skippedCount = 0

            for ticket in queuedTickets {
                let ticketId = ticket.id

                guard existingTicketIDs.contains(ticketId) == false else {
                    skippedCount += 1
                    continue
                }

                guard batchTicketIDs.insert(ticketId).inserted else {
                    skippedCount += 1
                    continue
                }

                db.records.append(NewDailyRecordModel(data: ticket.toRecordData()))
                existingTicketIDs.insert(ticketId)
                createdCount += 1
            }

            db.recordCreationQueue.removeAll()
            try context.save()

            logger.debug(
                "createDailyRecords 완료 (created: \(createdCount), skipped: \(skippedCount))"
            )
        } catch {
            logger.error("createDailyRecords 실패: \(error.localizedDescription, privacy: .public)")
        }
    }
}
