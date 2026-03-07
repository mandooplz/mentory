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


// MARK: - Error
public enum NewMentoryDBError: Error, Sendable {
    case containerUnavailable
    case databaseNotFound
    case recordNotFound
}


// MARK: - Interface
public protocol NewMentoryDBInterface: Actor, Sendable {
    func setUpIfNeeded()

    func setName(_ newName: String)
    func getName() -> String?

    func setCharacter(_ character: MentoryCharacter)
    func getCharacter() -> MentoryCharacter?

    func setMentorMessage(_ data: MessageData)
    func getMentorMessage() -> MessageData?

    func getRecordCount() -> Int
    func isSameDayRecordExist(for date: MentoryDate) -> Bool
    func getRecentRecord() -> NewDailyRecord?
    func getRecords() -> [RecordData]
    func getRecord(ticketId: UUID) -> NewDailyRecord?

    func getCompletedSuggestionsCount() -> Int
    func updateSuggestionStatus(targetId: UUID, isDone: Bool)

    func insertTicket(_ recordData: RecordData)
    func insertSuggestions(ticketId: UUID, suggestions: [SuggestionData]) async
    func createDailyRecords() async
}


// MARK: - Object
public actor NewMentoryDB: Sendable, NewMentoryDBInterface {
    // MARK: Core
    private static let defaultDatabaseID = UUID(
        uuidString: "00000000-0000-0000-0000-000000000000"
    ) ?? UUID()

    public static let shared = NewMentoryDB(id: defaultDatabaseID)

    nonisolated public let id: UUID

    nonisolated private let logger = Logger(
        subsystem: "MentoryDB.NewMentoryDBCore",
        category: "Storage"
    )

    private static let bootstrapLogger = Logger(
        subsystem: "MentoryDB.NewMentoryDBCore",
        category: "Bootstrap"
    )

    private static let container: ModelContainer? = {
        do {
            return try ModelContainer(
                for: NewMentoryDBModel.self,
                NewRecordTicket.self,
                NewDailyRecordModel.self,
                NewDailySuggestionModel.self
            )
        } catch {
            bootstrapLogger.error(
                "ModelContainer 초기화 실패: \(error.localizedDescription, privacy: .public)"
            )
            return nil
        }
    }()

    private init(id: UUID) {
        self.id = id
    }

    // MARK: Helpers
    static func makeContextForSharedContainer() throws -> ModelContext {
        guard let container = Self.container else {
            throw NewMentoryDBError.containerUnavailable
        }

        return ModelContext(container)
    }

    private func makeContext() throws -> ModelContext {
        try Self.makeContextForSharedContainer()
    }

    private func descriptor(for id: UUID) -> FetchDescriptor<NewMentoryDBModel> {
        FetchDescriptor<NewMentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
    }

    private func fetchDB(in context: ModelContext) throws -> NewMentoryDBModel {
        guard let db = try context.fetch(descriptor(for: id)).first else {
            throw NewMentoryDBError.databaseNotFound
        }

        return db
    }

    private func fetchOrCreateDB(in context: ModelContext) throws -> NewMentoryDBModel {
        if let db = try context.fetch(descriptor(for: id)).first {
            return db
        }

        let db = NewMentoryDBModel(id: id)
        context.insert(db)
        return db
    }

    private func updateDB(
        _ update: (NewMentoryDBModel) throws -> Void
    ) throws {
        let context = try makeContext()
        let db = try fetchOrCreateDB(in: context)

        try update(db)
        try context.save()
    }

    private func logError(_ action: String, error: Error) {
        logger.error("\(action, privacy: .public) 실패: \(error.localizedDescription, privacy: .public)")
    }

    // MARK: Setup
    public func setUpIfNeeded() {
        do {
            let context = try makeContext()
            _ = try fetchOrCreateDB(in: context)
            try context.save()

            logger.debug("setUpIfNeeded 완료")
        } catch {
            logError("setUpIfNeeded", error: error)
        }
    }

    // MARK: User
    public func setName(_ newName: String) {
        do {
            try updateDB { db in
                db.userName = newName
            }

            logger.debug("이름 저장 완료")
        } catch {
            logError("setName", error: error)
        }
    }

    public func getName() -> String? {
        do {
            let context = try makeContext()
            return try fetchDB(in: context).userName
        } catch {
            logError("getName", error: error)
            return nil
        }
    }

    public func setCharacter(_ character: MentoryCharacter) {
        do {
            try updateDB { db in
                db.userCharacter = character
            }

            logger.debug("캐릭터 저장 완료")
        } catch {
            logError("setCharacter", error: error)
        }
    }

    public func getCharacter() -> MentoryCharacter? {
        do {
            let context = try makeContext()
            return try fetchDB(in: context).userCharacter
        } catch {
            logError("getCharacter", error: error)
            return nil
        }
    }

    // MARK: Mentor Message
    public func setMentorMessage(_ data: MessageData) {
        do {
            try updateDB { db in
                db.messageCreatedAt = data.createdAt.rawValue
                db.messageContent = data.content
                db.messageCharacter = data.characterType
            }

            logger.debug("멘토 메시지 저장 완료")
        } catch {
            logError("setMentorMessage", error: error)
        }
    }

    public func getMentorMessage() -> MessageData? {
        do {
            let context = try makeContext()
            let db = try fetchDB(in: context)

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
            logError("getMentorMessage", error: error)
            return nil
        }
    }

    // MARK: Record
    public func getRecordCount() -> Int {
        do {
            let context = try makeContext()
            return try fetchDB(in: context).records.count
        } catch {
            logError("getRecordCount", error: error)
            return 0
        }
    }

    public func isSameDayRecordExist(for date: MentoryDate) -> Bool {
        do {
            let context = try makeContext()
            let db = try fetchDB(in: context)

            return db.records.contains { record in
                MentoryDate(record.recordDate).isSameDate(as: date)
            }
        } catch {
            logError("isSameDayRecordExist", error: error)
            return false
        }
    }

    public func getRecentRecord() -> NewDailyRecord? {
        do {
            let context = try makeContext()
            let db = try fetchDB(in: context)

            guard let latest = db.records.max(by: { $0.recordDate < $1.recordDate }) else {
                return nil
            }

            return NewDailyRecord(id: latest.id)
        } catch {
            logError("getRecentRecord", error: error)
            return nil
        }
    }

    public func getRecords() -> [RecordData] {
        do {
            let context = try makeContext()
            let db = try fetchDB(in: context)

            return db.records
                .sorted(by: { $0.recordDate > $1.recordDate })
                .map { $0.toRecordData() }
        } catch {
            logError("getRecords", error: error)
            return []
        }
    }

    public func getRecord(ticketId: UUID) -> NewDailyRecord? {
        do {
            let context = try makeContext()
            let db = try fetchDB(in: context)

            guard let target = db.records.first(where: { $0.ticketId == ticketId }) else {
                return nil
            }

            return NewDailyRecord(id: target.id)
        } catch {
            logError("getRecord", error: error)
            return nil
        }
    }

    // MARK: Suggestion
    public func getCompletedSuggestionsCount() -> Int {
        do {
            let context = try makeContext()
            let db = try fetchDB(in: context)

            return db.records.reduce(0) { total, record in
                total + record.suggestions.filter { $0.status }.count
            }
        } catch {
            logError("getCompletedSuggestionsCount", error: error)
            return 0
        }
    }

    public func updateSuggestionStatus(targetId: UUID, isDone: Bool) {
        do {
            let context = try makeContext()
            let db = try fetchDB(in: context)

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
            logError("updateSuggestionStatus", error: error)
        }
    }

    public func insertTicket(_ recordData: RecordData) {
        do {
            let context = try makeContext()
            let db = try fetchOrCreateDB(in: context)

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
            logError("insertTicket", error: error)
        }
    }

    public func insertSuggestions(ticketId: UUID, suggestions: [SuggestionData]) async {
        guard suggestions.isEmpty == false else {
            return
        }

        do {
            let context = try makeContext()
            let db = try fetchDB(in: context)

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
            logError("insertSuggestions", error: error)
        }
    }

    // MARK: Queue
    public func createDailyRecords() async {
        do {
            let context = try makeContext()
            let db = try fetchDB(in: context)

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
            logError("createDailyRecords", error: error)
        }
    }
}
