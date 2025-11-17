//
//  AlanLLMMock.swift
//  Mentory
//
//  Created by 김민우 on 11/18/25.
//
import Foundation
import Collections
import OSLog


// MARK: Mock
@MainActor
final class AlanLLMMock: Sendable {
    // MARK: core
    init() { }
    
    
    // MARK: state
    nonisolated let logger = Logger(subsystem: "AlanLLM.AlanLLMMock", category: "Domain")
    nonisolated let strs = ["Hello", "World", "Swift", "Great", "Is it fun?", "No, it's not fun."]
    var answerBox: [Question.ID: Answer] = [:]
    var questionQueue: Deque<Question> = []
    
    
    // MARK: action
    func processQuestions() {
        // capture
        guard questionQueue.isEmpty == false else {
            logger.error("queustionQueue가 비어 있습니다.")
            return
        }
        
        // mutate
        while questionQueue.isEmpty == false {
            let question = questionQueue.removeFirst()
            
            let randomString = strs.randomElement()!
            let randomAnswer = Answer(randomString)
            
            answerBox[question.id] = randomAnswer
        }
    }
    
    
    // MARK: value
    nonisolated
    struct Question: Sendable, Hashable, Identifiable {
        // MARK: codr
        let id: ID = ID()
        let content: String
        
        init(_ content: String) {
            self.content = content
        }
        
        
        // MARK: value
        struct ID: Sendable, Hashable {
            let rawValue = UUID()
        }
    }
    
    nonisolated
    struct Answer: Sendable, Hashable {
        // MARK: core
        let id = UUID()
        let content: String
        
        init(_ content: String) {
            self.content = content
        }
    }
    
    nonisolated
    struct AuthToken {
        // MARK: core
        let value: String
        
        init(_ value: String) {
            self.value = value
        }
    }
    
    nonisolated
    struct ID: Sendable, Hashable {
        // MARK: core
        let value: URL
        init(_ value: URL) {
            self.value = value
        }
    }
}
