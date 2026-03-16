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


// MARK: object
public actor NewDailyRecord: NewDailyRecordInterface {

    // MARK: Core
    init(objectID: UUID) {
        self.objectID = objectID
    }
    nonisolated public let objectID: UUID
    nonisolated private let logger = Logger()


    // MARK: state
    public var ticketID: UUID {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let descriptor = NewDailyRecordModel.descriptor(for: self.objectID)

                guard let record = try context.fetch(descriptor).first else {
                    throw NewMentoryDBError.recordNotFound
                }

                return record.id
            } catch {
                logger.fault("getTicketID 실패: \(error.localizedDescription, privacy: .public)")
                return UUID()
            }
        }
    }
    public var recordID: RecordID {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.objectID)

            guard let record = try context.fetch(descriptor).first else {
                throw NewMentoryDBError.recordNotFound
            }

            return .init(id: record.recordID)
        } catch {
            fatalError("getTicketID 실패: \(error.localizedDescription)")
        }
    }

    public var recordDate: MentoryDate {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let descriptor = NewDailyRecordModel.descriptor(for: self.objectID)

                guard let record = try context.fetch(descriptor).first else {
                    throw NewMentoryDBError.recordNotFound
                }

                return MentoryDate(record.recordDate)
            } catch {
                logger.error("getRecordDate 실패: \(error.localizedDescription, privacy: .public)")
                return MentoryDate(Date())
            }
        }
    }
    public var createdAt: MentoryDate {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let descriptor = NewDailyRecordModel.descriptor(for: self.objectID)

                guard let record = try context.fetch(descriptor).first else {
                    throw NewMentoryDBError.recordNotFound
                }

                return MentoryDate(record.createdAt)
            } catch {
                logger.error("getCreateAt 실패: \(error.localizedDescription, privacy: .public)")
                return MentoryDate(Date())
            }
        }
    }

    public var analyzedContent: String {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let descriptor = NewDailyRecordModel.descriptor(for: self.objectID)

                guard let record = try context.fetch(descriptor).first else {
                    throw NewMentoryDBError.recordNotFound
                }

                return record.analyzedResult
            } catch {
                logger.error("getAnalyzedContent 실패: \(error.localizedDescription, privacy: .public)")
                return ""
            }
        }
    }
    public var emotion: Emotion {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let descriptor = NewDailyRecordModel.descriptor(for: self.objectID)

                guard let record = try context.fetch(descriptor).first else {
                    throw NewMentoryDBError.recordNotFound
                }

                return record.emotion
            } catch {
                logger.error("getEmotion 실패: \(error.localizedDescription, privacy: .public)")
                return .neutral
            }
        }
    }

    public var suggestionSnapshots: [SuggestionSnapshot] {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.objectID)

            guard let record = try context.fetch(descriptor).first else {
                throw NewMentoryDBError.recordNotFound
            }

            return record.suggestions.map { $0.toData() }
        } catch {
            logger.error("getSuggestionDatas 실패: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }
    public func getSuggestion(suggestionID: SuggestionID) async -> NewDailySuggestion? {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.objectID)

            guard let dailyRecord = try context.fetch(descriptor).first else {
                logger.error("DailyRecord를 데이터베이스에서 찾지 못했습니다.")
                return nil
            }

            let dailySuggesion = dailyRecord.suggestions
                .first {
                    $0.suggestionID == suggestionID.id
                }
            
            if let dailySuggesion {
                return NewDailySuggestion(objectID: dailySuggesion.id)
            } else {
                return nil
            }
        } catch {
            logger.error("getSuggestionDatas 실패")
            return nil
        }
    }

    public var createSuggestionQueue: [SuggestionSnapshot] {
        get {
            []
        }
    }
    public func registerSnapshots(_ suggestionDatas: [SuggestionSnapshot]) async {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.objectID)

            guard let record = try context.fetch(descriptor).first else {
                throw NewMentoryDBError.recordNotFound
            }

            let suggestionModels = suggestionDatas.map { NewDailySuggestionModel(data: $0) }
            record.suggestions.append(contentsOf: suggestionModels)
            try context.save()
        } catch {
            logger.error("registerRecordSnapshot 실패: \(error.localizedDescription, privacy: .public)")
        }
    }


    // MARK: action


    public func createDailySuggestions() async {
        logger.debug("createDailySuggestions 스킵: queued suggestion model 없음")
    }
}
