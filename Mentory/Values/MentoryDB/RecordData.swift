//
//  RecordData.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation


// MARK: Value
nonisolated
public struct RecordData: Sendable, Hashable, Codable, Equatable {
    // MARK: core
    public let id: UUID
    
    public let recordDate: Date
    public let createdAt: Date
    
    public let analyzedResult: String
    public let emotion: Emotion
    
    
    public init(id: UUID, recordDate: Date, createdAt: Date, analyzedResult: String, emotion: Emotion) {
        self.id = id
        self.recordDate = recordDate
        self.createdAt = createdAt
        self.analyzedResult = analyzedResult
        self.emotion = emotion
    }
}
