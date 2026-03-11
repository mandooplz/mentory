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
    init(id: UUID) {
        self.id = id
    }
    nonisolated public let id: UUID
    nonisolated private let logger = Logger()


    // MARK: state
    public var ticketID: UUID {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let descriptor = NewDailyRecordModel.descriptor(for: self.id)

                guard let record = try context.fetch(descriptor).first else {
                    throw NewMentoryDBError.recordNotFound
                }

                return record.ticketId
            } catch {
                logger.fault("getTicketID 실패: \(error.localizedDescription, privacy: .public)")
                return UUID()
            }
        }
    }
    public var recordID: UUID {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.id)

            guard let record = try context.fetch(descriptor).first else {
                throw NewMentoryDBError.recordNotFound
            }

            return record.recordID
        } catch {
            logger.fault("getTicketID 실패: \(error.localizedDescription, privacy: .public)")
            return UUID()
        }
    }

    public var recordDate: MentoryDate {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let descriptor = NewDailyRecordModel.descriptor(for: self.id)

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
    public var createAt: MentoryDate {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let descriptor = NewDailyRecordModel.descriptor(for: self.id)

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
                let descriptor = NewDailyRecordModel.descriptor(for: self.id)

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
                let descriptor = NewDailyRecordModel.descriptor(for: self.id)

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

    public var suggestionDatas: [SuggestionData] {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.id)

            guard let record = try context.fetch(descriptor).first else {
                throw NewMentoryDBError.recordNotFound
            }

            return record.suggestions.map { $0.toData() }
        } catch {
            logger.error("getSuggestionDatas 실패: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }
    public func getSuggestion(suggestionID: UUID) async -> NewDailySuggestion? {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.id)

            guard let record = try context.fetch(descriptor).first else {
                return nil
            }

            guard let suggestion = record.suggestions.first(where: { $0.target == suggestionID }) else {
                return nil
            }

            return NewDailySuggestion(id: suggestion.id)
        } catch {
            logger.error("getSuggestionDatas 실패: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    public func addSuggestions(_ suggestionDatas: [SuggestionData]) async {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.id)
            
            guard let record = try context.fetch(descriptor).first else {
                logger.error("일치하는 NewDailyRecord를 데이터베이스에서 찾지 못했습니다.")
                return
            }
            
            let suggestions = suggestionDatas
                .map {
                    NewDailySuggestionModel(data: $0)
                }
            
            record.suggestions = suggestions
            
            try context.save()
        } catch {
            logger.error("getSuggestionDatas 실패: \(error.localizedDescription, privacy: .public)")
            return
        }
    }

    public var createSuggestionQueue: [SuggestionData] {
        get {
            []
        }
    }
    public func insertTicket(_ suggestionDatas: [SuggestionData]) async {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let descriptor = NewDailyRecordModel.descriptor(for: self.id)

            guard let record = try context.fetch(descriptor).first else {
                throw NewMentoryDBError.recordNotFound
            }

            let suggestionModels = suggestionDatas.map { NewDailySuggestionModel(data: $0) }
            record.suggestions.append(contentsOf: suggestionModels)
            try context.save()
        } catch {
            logger.error("insertTicket 실패: \(error.localizedDescription, privacy: .public)")
        }
    }


    // MARK: action


    public func createDailySuggestions() async {
        logger.debug("createDailySuggestions 스킵: queued suggestion model 없음")
    }
}
