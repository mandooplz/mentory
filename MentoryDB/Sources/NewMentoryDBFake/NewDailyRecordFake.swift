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
    internal init(objectID: UUID,
                  owner: NewMentoryDBFake,
                  recordID: RecordID,
                  recordDate: MentoryDate,
                  createAt: MentoryDate,
                  analyzedContent: String,
                  emotion: Emotion) {
        self.objectID = objectID
        self.owner = owner
        self.recordID = recordID
        self.recordDate = recordDate
        self.createdAt = createAt
        self.analyzedContent = analyzedContent
        self.emotion = emotion
    }


    // MARK: state
    public nonisolated let objectID: UUID
    public nonisolated let recordID: RecordID
    
    internal weak var owner: NewMentoryDBFake?

    public nonisolated let recordDate: MentoryDate
    public nonisolated let createdAt: MentoryDate

    public var analyzedContent: String
    public var emotion: Emotion

    internal var _suggestions: [NewDailySuggestionFake] = []
    public var suggestionSnapshots: [SuggestionSnapshot] {
        self._suggestions
            .map {
                SuggestionSnapshot(
                    objectID: $0.objectID,
                    suggestionID: $0.suggestionID,
                    parentRecord: $0.parentRecord,
                    content: $0.content,
                    isDone: $0.isDone
                )
            }
    }
    public func getSuggestion(suggestionID: SuggestionID) async -> NewDailySuggestionFake? {
        let suggestionSnapsho = suggestionSnapshots
            .first {
                $0.suggestionID == suggestionID
            }
        
        if let suggestionSnapsho {
            return NewDailySuggestionFake(snapshot: suggestionSnapsho)
        } else {
            return nil
        }
    }

    public var createSuggestionQueue: [SuggestionSnapshot] = []
    public func registerSnapshots(_: [SuggestionSnapshot]) async {
        fatalError()
    }


    // MARK: action
    public func createDailySuggestions() async {
        fatalError()
    }
}
