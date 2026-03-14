//
//  SuggestionSnapshot.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation


// MARK: Value
nonisolated
public struct SuggestionSnapshot: Sendable, Hashable, Codable {
    // MARK: core
    public let objectID: UUID
    public let suggestionID: SuggestionID
    
    public let parentRecord: RecordID
    
    public let content: String
    public let isDone: Bool
    
    public init(objectID: UUID, suggestionID: SuggestionID, parentRecord: RecordID, content: String, isDone: Bool) {
        self.objectID = objectID
        self.suggestionID = suggestionID
        self.parentRecord = parentRecord
        self.content = content
        self.isDone = isDone
    }
}
