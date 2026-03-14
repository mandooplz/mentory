//
//  NewDailySuggestionFake.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//

import NewMentoryDBCore
import Values
import Foundation


// MARK: fake
@MainActor
public final class NewDailySuggestionFake: NewDailySuggestionInterface {
    // MARK: core
    public init(objectID: UUID, suggestionID: SuggestionID, parentRecord: RecordID, content: String, isDone: Bool) {
        self.objectID = objectID
        self.suggestionID = suggestionID
        self.parentRecord = parentRecord
        self.content = content
        self.isDone = isDone
    }
    
    internal convenience init(snapshot: SuggestionSnapshot) {
        self.init(
            objectID: snapshot.objectID,
            suggestionID: snapshot.suggestionID,
            parentRecord: snapshot.parentRecord,
            content: snapshot.content,
            isDone: snapshot.isDone)
    }
    
    // MARK: state
    public nonisolated let objectID: UUID
    public nonisolated let suggestionID: SuggestionID
    public nonisolated let parentRecord: RecordID
    
    public var content: String
    public var isDone: Bool = false
    public func setDone(_ newValue: Bool) async {
        self.isDone = newValue
    }
}
