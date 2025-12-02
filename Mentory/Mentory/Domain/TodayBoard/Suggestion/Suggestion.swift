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
         content: String,
         isDone: Bool) {
        self.owner = owner
        self.source = source
        self.content = content
        self.isDone = isDone
    }
    
    // MARK: state
    nonisolated let id = UUID()
    
    weak var owner: TodayBoard?
    
    nonisolated let source: SuggestionID
    nonisolated let content: String
    
    @Published var isDone: Bool
    
    
    // MARK: action
    func markDone() async {
        // SwiftData의 UserSuggestion에 isDone 업데이트
        fatalError()
    }
    
    
    // MARK: value
}
