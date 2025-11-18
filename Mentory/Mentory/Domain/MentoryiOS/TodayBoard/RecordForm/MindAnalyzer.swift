//
//  MindAnalyzer.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class MindAnalyzer: Sendable, ObservableObject {
    // MARK: core
    init(owner: RecordForm) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    nonisolated let logger = Logger(subsystem: "MentoryiOS.MindAnalyzer", category: "Domain")
    weak var owner: RecordForm?
    
    @Published var isAnalyzing: Bool = false
    @Published var selectedCharacter: CharacterType? = nil
    @Published var mindType: MindType? = nil
    @Published var analyzedResult: String? = nil
    
    
    // MARK: action
    func startAnalyzing() async{
        // capture
        guard let textInput = owner?.textInput else {
            logger.error("TextInput이 비어있습니다.")
            return
        }

        guard textInput.isEmpty == false else {
            logger.error("textInput이 비어있습니다.")
            return
        }
        
        let selectedCharacter = selectedCharacter ?? .A
        
        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        let mentoryiOS = todayBoard.owner!
        let alanLLM = mentoryiOS.alanLLM
        
        
        // process
        let answer: AlanLLM.Answer
        do {
            let question = AlanLLM.Question(textInput)
            answer = try await alanLLM.question(question)
            
            
        } catch {
            logger.error("\(error)")
            return
        }
//        await callAPI(prompt: textInput)
        
        // mutate
        self.analyzedResult = answer.content
        self.mindType = .unPleasant
    }
    
    // 결과 오는지만 확인용
//    func callAPI(prompt: String) async {
//        // capture
//        let alanClientKey = Bundle.main.object(forInfoDictionaryKey: "ALAN_API_TOKEN") as Any
//        print("🔑 ALAN_API_TOKEN raw:", alanClientKey)
//        
//        print("ALAN_API_TOKEN =", alanClientKey)
//        
//        guard let apiToken = Bundle.main.object(forInfoDictionaryKey: "ALAN_API_TOKEN") as? String,
//              apiToken.isEmpty == false else {
//            print("ALAN_API_TOKEN 없음")
//            return
//        }
//        var urlBuilder = URLComponents(string: "https://kdt-api-function.azurewebsites.net/api/v1/question")!
//        urlBuilder.queryItems = [
//            URLQueryItem(name: "client_id", value: apiToken),
//            URLQueryItem(name: "content", value: prompt)
//        ]
//        
//        guard let requestURL = urlBuilder.url else {
//            print("URL 생성 실패")
//            return
//        }
//        
//        // process
//        do {
//            let (data, _) = try await URLSession.shared.data(from: requestURL)
//            let text = String(data: data, encoding: .utf8) ?? ""
//            print("요청 결과:", text)
//            
//            self.mindType = .slightlyUnpleasant
//            self.analyzedResult = text
//            
//        } catch {
//            print("요청 실패:", error)
//        }
//        
//        // mutate
//    }
    
    
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
