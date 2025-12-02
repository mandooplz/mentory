//
//  MessageData.swift
//  Values
//
//  Created by JAY on 11/26/25.
//
import Foundation


// MARK: value
nonisolated
public struct MessageData: Sendable, Hashable, Codable {
    // MARK: core
    public let createdAt: Date
    public let content: String
    
    public let characterType: MentoryCharacter
    
    public init(createdAt: Date = .now,
                content: String,
                characterType: MentoryCharacter) {
        self.createdAt = createdAt
        self.content = content
        self.characterType = characterType
    }
}
