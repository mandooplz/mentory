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
    func setQuestion(_: FirebaseQuestion) async
    func setCharacter(_: MentoryCharacter) async
}
