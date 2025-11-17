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
    init(owner: RecordForm) { self.owner = owner }
    
    
    // MARK: state
    nonisolated let owner: RecordForm
    nonisolated let id = UUID()
    @Published var isAnalyzing: Bool = true
    @Published var selectedCharacter: CharacterType? = nil
    @Published var mindType: MindType? = nil
    @Published var result: String? = nil
    
    
    // MARK: action
    // 분석(LLM에게 보내서) >> 결과 기다려서 반환해야 하는지?(이파일에서 가지고 있어야하는지)
    // RecordForm에서 갖고있는 사용자가 입력한 여러 상태들을
    func startAnalyzing() {
        // capture
        guard let character = selectedCharacter else { return }
        
        //process
        //연산에 해당하는 부분 모든 상태를 읽어온다음에 그값으로 연산...
        //ex)DB에 저장하거나 네트워크 호출
        
        // mutate
        // 연산이 끝난 값을 가지고 상태를 변경해주거나 등등
        
    }
    
    // MARK: value
    
    enum CharacterType: Sendable {
        case A
        case B
    }
    
    enum MindType: Sendable {
        case veryUnpleasant
        case unPleasant
        case slightlyUnpleasant
        case neutral
        case slightlyPleasant
        case pleasant
        case veryPleasant
    }
}
