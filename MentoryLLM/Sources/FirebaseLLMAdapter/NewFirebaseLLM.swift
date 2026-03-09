//
//  NewFirebaseLLM.swift
//  MentoryLLM
//
//  Created by 김민우 on 3/9/26.
//

import Values
import OSLog
import FirebaseAI
import FirebaseCore
import Foundation





// MARK: object
public actor NewFirebaseLLM: NewFirebaseLLMInterface {
    // MARK: core
    private let logger = Logger()
    
    public init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash-lite")
    }
    
    
    // MARK: state
    private let ai: FirebaseAI
    private let model: GenerativeModel
    
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
        let rawText: String
        do {
            let content = FirebaseContent(question: question)
            
            let response = try await model.generateContent([content.rawValue])
            rawText = response.text ?? ""
            
        } catch {
            logger.error("Firebase LLM 오류: \(error.localizedDescription, privacy: .public)")
            return
        }
        
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
        let jsonSchema = Schema.object(
            properties: [
                "mindType": .enumeration(values: Emotion.getAllEmotions() ),
                "empathyMessage": .string(description: character.messageDescription),
                "actionKeywords": Schema.array(
                    items: .string(description: "사용자의 감정 상태에 따른 행동 추천"),
                    minItems: 3,
                    maxItems: 3),
            ])
        
        let newModel = ai.generativeModel(
            modelName: "gemini-2.5-flash-lite",
            // In the generation config, set the `responseMimeType` to `application/json`
            // and pass the JSON schema object into `responseSchema`.
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: jsonSchema
            )
        )
        
        do {
            let content = FirebaseContent(question: question)
            let response = try await newModel.generateContent([content.rawValue])
            
            guard let data = response.text?.data(using: .utf8) else {
                return
            }
            
            let analysis = try JSONDecoder().decode(FirebaseAnalysis.self, from: data)
            
            
            // mutate
            self.setAnalysis(analysis)
        } catch {
            logger.error("Firebase LLM 오류: \(error.localizedDescription, privacy: .public)")
            return
        }
    }
    
    
    // MARK: value
    fileprivate struct FirebaseContent {
        fileprivate let rawValue: ModelContent
        fileprivate init(rawValue: ModelContent) {
            self.rawValue = rawValue
        }
        
        fileprivate init(question: FirebaseQuestion) {
            var parts: [any Part] = []

            // 텍스트 추가
            parts.append(TextPart(question.content))

            // 이미지 추가 (최대 1개)
            if let imageData = question.imageData {
                parts.append(InlineDataPart(data: imageData, mimeType: "image/jpeg"))
            }

            // 음성 추가 (최대 1개, wav 포맷)
            if let voiceURL = question.voiceURL {
                let voiceData = try! Data(contentsOf: voiceURL)
                parts.append(InlineDataPart(data: voiceData, mimeType: "audio/wav"))
            }

            self.rawValue = ModelContent(role: "user", parts: parts)
        }
    }
}
