//
//  FirebaseLLMMock.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Values



// MARK: Mock
nonisolated
struct FirebaseLLMMock: FirebaseLLMInterface {
    func question(_ question: FirebaseQuestion) async throws -> FirebaseAnswer {
        fatalError()
    }
    
    func getEmotionAnalysis(_: FirebaseQuestion) async throws -> FirebaseAnalysis {
        fatalError()
    }
}
