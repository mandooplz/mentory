//
//  NewFirebaseLLMFake.swift
//  MentoryLLM
//
//  Created by 김민우 on 3/9/26.
//

import Values
import OSLog
import NewFirebaseLLM


// MARK: object
public actor NewFirebaseLLMFake: NewFirebaseLLMInterface {
    // MARK: core
    private let logger = Logger()
    public init() { }
    
    
    // MARK: state
    private var question: FirebaseQuestion?
    public func setQuestion(_ rawValue: FirebaseQuestion) {
        if self.question == nil {
            question = rawValue
        } else {
            logger.error("question already set")
        }
    }
    
    public private(set) var answer: FirebaseAnswer?
    private func setAnswer(_ rawValue: FirebaseAnswer) {
        if self.answer == nil {
            answer = rawValue
        } else {
            logger.error("answer already set")
        }
    }
    
    private var character: MentoryCharacter?
    public func setCharacter(_ rawValue: MentoryCharacter) {
        if self.character == nil {
            self.character = rawValue
        } else {
            logger.error("NewFirebaseLLM.character가 이미 설정되어 있습니다.")
        }
    }
    
    public private(set) var analysis: FirebaseAnalysis?
    private func setAnalysis(_ rawValue: FirebaseAnalysis) {
        if self.analysis == nil {
            self.analysis = rawValue
        } else {
            logger.error("analysis already set")
        }
    }
    
    
    // MARK: action
    public func getAnswer() async {
        // capture
        guard let question else {
            logger.error("question이 설정되지 않았습니다.")
            return
        }
        
        guard self.answer == nil else {
            logger.error("이미 answer가 존재합니다.")
            return
        }
        
        // process
        let rawText = "오늘도 기록을 남겨줘서 고마워. 지금 느끼는 감정들을 천천히 바라보면서, 스스로를 너무 몰아붙이지 않았으면 좋겠어."
        let answer = FirebaseAnswer(rawText)
            .removeCodeBlockFence()
        
        // mutate
        self.setAnswer(answer)
    }
    
    public func getAnalysis() async {
        // capture
        guard let question else {
            logger.error("question이 설정되어 있지 않습니다.")
            return
        }
        
        guard let character else {
            logger.error("character가 설정되어 있지 않습니다.")
            return
        }
        
        guard self.analysis == nil else {
            logger.error("이미 answer가 존재합니다.")
            return
        }
        
        
        // process
        let analysis = FirebaseAnalysis(
            mindType: .neutral,
            empathyMessage: character.messageDescription.isEmpty
                ? "지금의 마음을 충분히 잘 들여다보고 있어요. 작은 감정도 소중하게 다뤄보세요."
                : "지금의 마음을 충분히 잘 들여다보고 있어요. 작은 감정도 소중하게 다뤄보세요.",
            actionKeywords: ["산책", "심호흡", "감정정리"]
        )
        
        self.setAnalysis(analysis)
    }
}
