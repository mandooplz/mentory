//
//  DailyRecordModel.swift
//  Mentory
//
//  Created by 김민우 on 11/23/25.
//
import Foundation
import Values
import Collections


// MARK: Fake
@MainActor
final class DailyRecordFake: Sendable {
    // MARK: core
    init(owner: MentoryDatabaseFake? = nil,
         ticketId: UUID,
         recordDate: MentoryDate,
         createAt: MentoryDate,
         analyzedContent: String,
         emotion: Emotion) {
        self.owner = owner
        self.ticketId = ticketId
        self.recordDate = recordDate
        self.createAt = createAt
        self.analyzedContent = analyzedContent
        self.emotion = emotion
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: MentoryDatabaseFake?
    
    nonisolated let ticketId: UUID
    
    nonisolated let recordDate: MentoryDate
    nonisolated let createAt: MentoryDate
    
    var analyzedContent: String
    var emotion: Emotion
    
    var createSuggestionQueue: Deque<SuggestionData> = []
    func insertTicket(_ suggestionDatas: [SuggestionData]) {
        self.createSuggestionQueue.append(contentsOf: suggestionDatas)
    }
    var suggestions: [DailySuggestionFake] = []
    func getSuggestions() -> [SuggestionData] {
        return self.suggestions
            .map { dailySuggestion in
                SuggestionData(
                        target: dailySuggestion.target,
                        content: dailySuggestion.content,
                        isDone: dailySuggestion.isDone
                    )
            }
    }


    // MARK: action
    func createDailySuggestions() {
        // mutate
        while createSuggestionQueue.isEmpty == false {
            let suggestionData = createSuggestionQueue.removeFirst()
            
            let newSuggestion = DailySuggestionFake(
                owner: self,
                ticketId: suggestionData.id,
                target: suggestionData.target,
                content: suggestionData.content,
                isDone: suggestionData.isDone
            )
            
            suggestions.append(newSuggestion)
        }
    }

    
    
    // MARK: value
}
