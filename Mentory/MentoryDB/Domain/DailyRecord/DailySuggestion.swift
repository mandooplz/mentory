//
//  DailySuggestion.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import SwiftData


// MARK: Object
actor DailySuggestion {
    // MARK: core
    
    
    // MARK: state
    
    
    // MARK: action
    
    
    // MARK: value
    @Model
    final class DailySuggestionModel {
        @Attribute(.unique) var id: UUID
        
        init(id: UUID) {
            self.id = id
        }
    }
}
