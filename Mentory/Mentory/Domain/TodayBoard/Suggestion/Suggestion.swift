//
//  Suggestion.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import Combine
import Values


// MARK: Object
@MainActor
final class Suggestion: Sendable, ObservableObject {
    // MARK: core
    init(source: NewSuggestionData,
         isDone: Bool) {
        self.source = source
        self.isDone = isDone
    }
    
    // MARK: state
    nonisolated let source: NewSuggestionData
    
    @Published var isDone: Bool
    
    
    // MARK: action
    func markDone() async {
        fatalError()
    }
    
    
    // MARK: value
}
