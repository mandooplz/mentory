//
//  NewSuggestionData.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation


// MARK: Value
nonisolated
public struct NewSuggestionData: Sendable, Hashable, Codable {
    // MARK: core
    public let id: UUID
    
    public let content: String
    public let status: Status
    
    
    // MARK: Value
    public enum Status: Sendable, Hashable, Codable {
        case ready
        case done
    }
}
