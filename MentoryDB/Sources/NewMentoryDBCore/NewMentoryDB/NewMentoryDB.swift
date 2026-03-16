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
    
    public var records: [RecordSnapshot] {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            return db.records
                .sorted(by: { $0.recordDate > $1.recordDate })
                .map { $0.snapshot }
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

            return NewDailyRecord(objectID: latest.id)
        } catch {
            logger.error("getRecentRecord 실패: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    public func getRecord(objectID: UUID) -> NewDailyRecord? {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            guard let dailyRecord = db.records.first(where: { $0.id == objectID }) else {
                return nil
            }

            return NewDailyRecord(objectID: dailyRecord.id)
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
    public func getRecord(recordID: RecordID) -> NewDailyRecord? {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            guard let dailyRecord = db.records.first(where: { $0.recordID == recordID.id }) else {
                return nil
            }

            return NewDailyRecord(objectID: dailyRecord.id)
        } catch {
            logger.error("getRecord 실패: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    public func registerRecordSnapshot(_ snapshot: RecordSnapshot) {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let db = try NewMentoryDBConfig.default.fetchDB(in: context)

            guard db.records.contains(where: { $0.id == snapshot.objectID }) == false else {
                logger.debug("registerRecordSnapshot 중복 스킵(records)")
                return
            }

            guard db.recordCreationQueue.contains(where: { $0.id == snapshot.objectID }) == false else {
                logger.debug("registerRecordSnapshot 중복 스킵(queue)")
                return
            }

            db.recordCreationQueue.append(NewRecordTicket(snapshot: snapshot))
            try context.save()
            logger.debug("registerRecordSnapshot 완료")
        } catch {
            logger.error("registerRecordSnapshot 실패: \(error.localizedDescription, privacy: .public)")
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

            let tickets = db.recordCreationQueue
            var existingTicketIDs = Set(db.records.map { $0.id })
            var batchTicketIDs: Set<UUID> = []

            var createdCount = 0
            var skippedCount = 0

            for ticket in tickets {
                let objectID = ticket.id

                guard existingTicketIDs.contains(objectID) == false else {
                    skippedCount += 1
                    continue
                }

                guard batchTicketIDs.insert(objectID).inserted else {
                    skippedCount += 1
                    continue
                }

                // ticket으로부터 RecordSnapshot을 넎는다.
                db.records.append(
                    NewDailyRecordModel(
                        data: ticket.toRecordSnapshot()
                    )
                )
                existingTicketIDs.insert(objectID)
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
