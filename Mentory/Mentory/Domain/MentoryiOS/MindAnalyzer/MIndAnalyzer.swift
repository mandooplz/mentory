//
//  MIndAnalyzer.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//

import Foundation
import Combine

// MARK: Object
@MainActor final class MindAnalyzer: Sendable, ObservableObject {
    // MARK: core
    init(owner: MindAnalyzer) { self.owner = owner }
    
    
    // MARK: state
    nonisolated let owner: MindAnalyzer
    @Published var isAnalyzing: Bool = true
    @Published var selectedCharacter: CharacterType? = nil
    nonisolated let mindStatus: MindType? = nil
    
    
    // MARK: action
    // 분석(LLM에게 보내서) >> 결과 기다려서 반환해야 하는지?(이파일에서 가지고 있어야하는지)
    func startAnalyzing(text: String) {
        // capture
        guard let character = selectedCharacter else { return }
        
        // mutate
        
    }
    
    // MARK: value
    
}
