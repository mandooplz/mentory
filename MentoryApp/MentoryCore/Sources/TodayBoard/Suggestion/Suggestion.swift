//
//  Suggestion.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//

import Combine
import Foundation
import OSLog
import Values

// MARK: object
@MainActor
public final class Suggestion: Sendable, ObservableObject {
    // MARK: core
    private nonisolated let logger = Logger()
    
    public init(
        owner: TodayBoard,
        parentRecord: RecordID,
        suggestionID: SuggestionID,
        content: String,
        isDone: Bool
    ) {
        self.owner = owner
        self.parentRecord = parentRecord
        self.suggestionID = suggestionID
        self.content = content
        self.isDone = isDone
    }

    

    // MARK: state
    public nonisolated let objectID: ObjectID = .random
    public nonisolated let suggestionID: SuggestionID
    public weak var owner: TodayBoard?

    public nonisolated let parentRecord: RecordID
    
    public nonisolated let content: String
    @Published public var isDone: Bool

    // MARK: action
    public func markDone() async {
        // capture
        let todayBoard = self.owner!
        let mentoryiOS = todayBoard.owner!
        let newMentoryDB = mentoryiOS.newMentoryDB
        let suggestionID = self.suggestionID
        let isDone = self.isDone

        logger.debug("markDone 호출: isDone=\(isDone)")

        // process
        guard let newDailyRecord = await newMentoryDB.getRecord(recordID: parentRecord) else {
            logger.error("NewMentoryDB에서 DailyRecord가 검색되지 않았습니다.")
            return
        }
        
        guard let newDailySuggestion = await newDailyRecord.getSuggestion(suggestionID: suggestionID)
        else {
            logger.error("NewDailyRecord에서 일치하는 Suggestion 객체를 찾을 수 없습니다.")
            return
        }

        await newDailySuggestion.setDone(isDone)
    }
    
    
    // MARK: value
    public nonisolated struct ObjectID: ObjectIdentifier {
        public let id: UUID
        public init(id: UUID) {
            self.id = id
        }
    }
}
