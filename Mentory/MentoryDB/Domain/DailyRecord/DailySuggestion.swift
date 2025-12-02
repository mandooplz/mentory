//
//  DailySuggestion.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import SwiftData
import Values
import OSLog


// MARK: Object
actor DailySuggestion {
    // MARK: core
    init(id: UUID) {
        self.id = id
    }
    nonisolated let id: UUID
    nonisolated let logger = Logger(subsystem: "MentoryDB.DailySuggestion", category: "Domain")
    
    
    // MARK: state
    
    
    // MARK: action
    
    
    // MARK: value
    @Model
    final class DailySuggestionModel {
        @Attribute(.unique) var id: UUID
        
        var content: String
        var status: SuggestionData.Status
        
        init(id: UUID,
             content: String,
             status: SuggestionData.Status) {
            self.id = id
            self.content = content
            self.status = status
        }
    }
}
