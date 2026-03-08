//
//  SuggestionData.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation


// MARK: Value
nonisolated
public struct SuggestionData: Sendable, Hashable, Codable {
    // MARK: core
    public let objectID: UUID
    
    public let parentRecord: UUID
    public let target: SuggestionID
    
    public let content: String
    public let isDone: Bool
    
    public init(id: UUID = .init(),
                parentRecord: UUID,
                target: SuggestionID = .random,
                content: String,
                isDone: Bool = false) {
        self.objectID = id
        self.parentRecord = parentRecord
        self.target = target
        self.content = content
        self.isDone = isDone
    }
}
