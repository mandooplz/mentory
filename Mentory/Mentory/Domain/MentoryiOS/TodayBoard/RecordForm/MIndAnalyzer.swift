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
    @Published var analyzedResult: String? = nil
    
    
    // MARK: action
    // 분석(LLM에게 보내서) >> 결과 기다려서 반환해야 하는지?(이파일에서 가지고 있어야하는지)
    // RecordForm에서 갖고있는 사용자가 입력한 여러 상태들을
    func startAnalyzing() {
        // capture
        let textInput = owner.textInput
        guard textInput.isEmpty == false else {
            return
        }
        guard let imageInput = owner.imageInput else { return }
        guard let voiceInput = owner.voiceInput else { return }
    
        //process
        //연산에 해당하는 부분 모든 상태를 읽어온다음에 그값으로 연산...
        //ex)DB에 저장하거나 네트워크 호출
        
        
        // mutate
        // 연산이 끝난 값을 가지고 상태를 변경해주거나 등등
        selectedCharacter = CharacterType.A
        mindType = MindType.slightlyUnpleasant
        analyzedResult = "오늘은 전체적으로 큰 기복 없이 흘러갔지만, 마음속에는 설명하기 어려운 잔잔한 피로가 조금씩 쌓여 가는 기분이 있었어요. 특별히 힘들었던 건 아니지만 집중이 잘 되지 않는 순간들이 있었고, 그럴 때마다 잠시 숨을 고르며 스스로를 다독여야 했어요. 전반적으로 무난한 하루였지만, 저도 모르게 마음이 조금 무거워지는 시간이 종종 찾아와 조용히 쉬고 싶은 감정이 자연스럽게 떠오르는 하루였어요."
        
        
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
