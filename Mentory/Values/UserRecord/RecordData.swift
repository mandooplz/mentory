//
//  RecordData.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import Foundation


// MARK: value
nonisolated
public struct RecordData: Sendable, Hashable, Codable {
    // MARK: core
    public let id: UUID
    public let createdAt: Date
    
    public let content: String
    public let analyzedResult: String
    public let emotion: Emotion

    // 행동 추천 (무조건 3개)
    public let actionTexts: [String]
    public let actionCompletionStatus: [Bool]

    public init(id: UUID, createdAt: Date, content: String, analyzedResult: String, emotion: Emotion, actionTexts: [String] = [], actionCompletionStatus: [Bool] = []) {
        self.id = id
        self.createdAt = createdAt
        self.content = content
        self.analyzedResult = analyzedResult
        self.emotion = emotion
        self.actionTexts = actionTexts
        self.actionCompletionStatus = actionCompletionStatus
    }
}
