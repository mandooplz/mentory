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
    var answerBox: [AlanLLM.Question.ID: AlanLLM.Answer] = [:]
    var questionQueue: Deque<AlanLLM.Question> = []
    
    
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
            let randomAnswer = AlanLLM.Answer(randomString)
            
            answerBox[question.id] = randomAnswer
        }
    }
    
    
    // MARK: value

}
