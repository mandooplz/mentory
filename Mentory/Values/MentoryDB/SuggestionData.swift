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
    public let id: UUID
    
    public let content: String
    public let status: Status
    
    public init(
        id: UUID,
        content: String,
        status: Status) {
        self.id = id
        self.content = content
        self.status = status
    }
    
    
    // MARK: Value
    public enum Status: Sendable, Hashable, Codable {
        case ready
        case done
    }
}
