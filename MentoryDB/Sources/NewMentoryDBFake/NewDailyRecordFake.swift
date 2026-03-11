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
                  ticketID: UUID,
                  recordDate: MentoryDate,
                  createAt: MentoryDate,
                  analyzedContent: String,
                  emotion: Emotion) {
        self.id = id
        self.owner = owner
        self.recordID = recordID
        self.ticketID = ticketID
        self.recordDate = recordDate
        self.createAt = createAt
        self.analyzedContent = analyzedContent
        self.emotion = emotion
    }


    // MARK: state
    public nonisolated let id: UUID
    public var recordID: UUID
    internal weak var owner: NewMentoryDBFake?

    public nonisolated let ticketID: UUID

    public nonisolated let recordDate: MentoryDate
    public nonisolated let createAt: MentoryDate

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
