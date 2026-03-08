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
    public typealias DailySuggestionObject = NewDailySuggestion

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
                logger.error("getTicketID 실패: \(error.localizedDescription, privacy: .public)")
                return UUID()
            }
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

//    public var suggestions: [NewDailySuggestion] {
//        get {
//            do {
//                let context = try NewMentoryDBConfig.default.makeContext()
//                let descriptor = NewDailyRecordModel.descriptor(for: self.id)
//
//                guard let record = try context.fetch(descriptor).first else {
//                    throw NewMentoryDBError.recordNotFound
//                }
//
//                return record.suggestions.map { NewDailySuggestion(id: $0.id) }
//            } catch {
//                logger.error("getSuggestions 실패: \(error.localizedDescription, privacy: .public)")
//                return []
//            }
//        }
//    }
    public var suggestionDatas: [SuggestionData] {
        get {
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
