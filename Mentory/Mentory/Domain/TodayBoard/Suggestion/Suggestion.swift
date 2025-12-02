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
         source: SuggestionID,
         isDone: Bool) {
        self.owner = owner
        self.source = source
        self.isDone = isDone
    }
    
    // MARK: state
    nonisolated let id = UUID()
    
    weak var owner: TodayBoard?
    
    nonisolated let source: SuggestionID
    
    @Published var isDone: Bool
    
    
    // MARK: action
    func markDone() async {
        fatalError()
    }
    
    
    // MARK: value
}
