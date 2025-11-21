//
//  RecordData.swift
//  Mentory
//
//  Created by 김민우 on 11/20/25.
//
import Foundation


// MARK: value
nonisolated
struct RecordData: Sendable, Hashable, Codable {
    // MARK: core
    let id: UUID
    let createdAt: Date
    
    let content: String
    let emotion: Emotion
    
    init(id: UUID = .init(), createdAt: Date, content: String, emotion: Emotion) {
        self.id = id
        self.createdAt = createdAt
        self.content = content
        self.emotion = emotion
    }
    
    
    // MARK: value
    nonisolated
    enum Emotion: String, Codable {
        case happy, sad, neutral, surprised, scared
    }
}
