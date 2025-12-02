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
    init(owner: TodayBoard,
         source: NewSuggestionData,
         isDone: Bool) {
        self.owner = owner
        self.source = source
        self.isDone = isDone
    }
    
    // MARK: state
    weak var owner: TodayBoard?
    
    nonisolated let source: NewSuggestionData
    
    @Published var isDone: Bool
    
    
    // MARK: action
    func markDone() async {
        fatalError()
    }
    
    
    // MARK: value
}
