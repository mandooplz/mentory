//
//  NewFirebaseLLMInterface.swift
//  MentoryLLM
//
//  Created by 김민우 on 3/9/26.
//


import Values
import OSLog
import FirebaseAI
import FirebaseCore
import Foundation


// MARK: protocol
public protocol NewFirebaseLLMInterface: Sendable {
    // MARK: state
    func setQuestion(_: FirebaseQuestion) async
    func setCharacter(_: MentoryCharacter) async
    
    var answer: FirebaseAnswer? { get async }
    var analysis: FirebaseAnalysis? { get async}
}
