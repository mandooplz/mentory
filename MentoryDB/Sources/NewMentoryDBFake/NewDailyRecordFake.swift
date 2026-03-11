//
//  NewDailyRecordFake.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//
import NewMentoryDBCore
import Values
import Foundation


// MARK: fake
@MainActor
public final class NewDailyRecordFake: NewDailyRecordInterface {


    // MARK: core
    internal init(id: UUID,
                  owner: NewMentoryDBFake,
                  recordID: UUID,
                  recordDate: MentoryDate,
                  createAt: MentoryDate,
                  analyzedContent: String,
                  emotion: Emotion) {
        self.objectID = id
        self.owner = owner
        self.recordID = recordID
        self.recordDate = recordDate
        self.createdAt = createAt
        self.analyzedContent = analyzedContent
        self.emotion = emotion
    }


    // MARK: state
    public nonisolated let objectID: UUID
    public var recordID: UUID
    internal weak var owner: NewMentoryDBFake?

    public nonisolated let recordDate: MentoryDate
    public nonisolated let createdAt: MentoryDate

    public var analyzedContent: String
    public var emotion: Emotion

    public var suggestionDatas: [SuggestionData] = []
    public func getSuggestion(suggestionID: UUID) async -> NewDailySuggestionFake? {
        fatalError()
    }
    public func addSuggestions(_ suggestionDatas: [SuggestionData]) async {
        self.suggestionDatas.append(contentsOf: suggestionDatas)
    }

    public var createSuggestionQueue: [SuggestionData] = []
    public func insertTicket(_: [SuggestionData]) async {
        fatalError()
    }


    // MARK: action
    public func createDailySuggestions() async {
        fatalError()
    }
}
