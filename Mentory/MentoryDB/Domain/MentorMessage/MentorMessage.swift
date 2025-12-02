//
//  MentorMessage.swift
//  MentoryDB
//
//  Created by JAY on 11/26/25.
//

import Foundation
import SwiftData
import OSLog
import Values

// MARK: Object
actor MentorMessage: Sendable {
    //MARK: core
    init(id: UUID) {
        self.id = id
    }
    nonisolated let id: UUID
    nonisolated let logger = Logger(subsystem: "MentoryDB.MentorMessage", category: "Domain")
    
    //MARK: state
    
    //MARK: action
    
    //MARK: value

    @Model
    final class MentorMessageModel {
        // MARK: core
        @Attribute(.unique) var id: UUID
        
        var createdAt: Date
        
        var content: String
        var characterType: MentoryCharacter

        init(id: UUID = UUID(), createdAt: Date, content: String, characterType: MentoryCharacter) {
            self.id = id
            self.createdAt = createdAt
            self.content = content
            self.characterType = characterType
        }
        
        init(data: MessageData) {
            self.id = UUID()
            self.createdAt = data.createdAt
            self.content = data.content
            self.characterType = data.characterType
        }
        
        
        // MARK: operator
        func toMessageData() -> MessageData {
            return .init(
                createdAt: self.createdAt,
                content: self.content,
                characterType: self.characterType)
        }

    }
    
    
}
