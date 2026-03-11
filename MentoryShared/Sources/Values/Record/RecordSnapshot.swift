//
//  RecordSnapshot.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation


// MARK: Value
nonisolated
public struct RecordSnapshot: Sendable {
    // MARK: core
    public let objectID: UUID
    public let recordID: RecordID
    
    public let recordDate: MentoryDate
    public let createdAt: MentoryDate
    
    public let analyzedResult: String
    public let emotion: Emotion
    
    
    public init(objectID: UUID,
                recordID: RecordID = .random,
                recordDate: MentoryDate,
                createdAt: MentoryDate = .now,
                analyzedResult: String,
                emotion: Emotion) {
        self.objectID = objectID
        self.recordID = recordID
        self.recordDate = recordDate
        self.createdAt = createdAt
        self.analyzedResult = analyzedResult
        self.emotion = emotion
    }
}
