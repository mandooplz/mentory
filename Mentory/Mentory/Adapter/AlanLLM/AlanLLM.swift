//
//  AlanLLM.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import OSLog
import FirebaseAILogic

// MARK: Domain Interface
protocol AlanLLMInterface: Sendable {
    func question(_ question: AlanLLM.Question) async throws -> AlanLLM.Answer
    func resetState(token: AlanLLM.AuthToken) async throws
}


// MARK: Domain
nonisolated
struct AlanLLM: AlanLLMInterface {
    // MARK: core
    nonisolated let id = ID(URL(string: "https://kdt-api-function.azurewebsites.net/api/v1")!)
    nonisolated let logger = Logger(subsystem: "AlanLLM.AlanLLMFlow", category: "Domain")
    
    
    // MARK: flows
    @concurrent
    func question(_ question: Question) async throws -> Answer {
        logger.info("Firebase LLM 요청 시작")

        // 1) Firebase LLM 인스턴스 생성
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        let model = ai.generativeModel(modelName: "gemini-2.5-flash-lite")

        // 2) Firebase Gemini 호출
        let response: GenerateContentResponse
        do {
            response = try await model.generateContent(question.content)
        } catch {
            logger.error("Firebase AI 호출 실패: \(error.localizedDescription)")
            throw AlanLLM.Error.networkError(error)
        }

        // 3) 텍스트 추출
        guard let text = response.text, !text.isEmpty else {
            logger.error("Firebase AI 응답이 비어 있음")
            throw AlanLLM.Error.invalidResponse
        }

        logger.info("Firebase LLM 응답 성공: \(text)")

        // 4) MindAnalyzer가 기대하는 Answer 형태로 wrapping
        let dummyAction = Answer.Action(
            name: "firebase",
            speak: "firebase"
        )

        return Answer(action: dummyAction, content: text)
    }

    
    @concurrent
    func resetState(token: AuthToken = .current) async throws {
        // Alan 서버 상태 초기화용 → Firebase에서는 필요 없음
        logger.info("Firebase LLM은 상태 초기화를 필요로 하지 않습니다.")
    }

    

    
    // MARK: value
    nonisolated
    enum Error: Swift.Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case networkError(Swift.Error)
        case decodingError(Swift.Error)
        case httpError(statusCode: Int)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "유효하지 않은 URL입니다."
            case .invalidResponse:
                return "서버 응답이 유효하지 않습니다."
            case .networkError(let error):
                return "네트워크 오류: \(error.localizedDescription)"
            case .decodingError(let error):
                return "데이터 파싱 오류: \(error.localizedDescription)"
            case .httpError(let statusCode):
                return "HTTP 오류 (상태 코드: \(statusCode))"
            }
        }
    }
    
    nonisolated
    struct Question: Sendable, Hashable, Identifiable {
        // MARK: codr
        let id: ID = ID()
        let content: String
        
        init(_ content: String) {
            self.content = content
        }
        
        
        // MARK: value
        struct ID: Sendable, Hashable {
            let rawValue = UUID()
        }
    }
    
    nonisolated
    struct Answer: Sendable, Codable {
        // MARK: core
        let action: Action
        let content: String
        
        nonisolated
        struct Action: Sendable, Codable {
            let name: String
            let speak: String
        }
    }
    
    nonisolated
    struct AuthToken {
        // MARK: core
        let value: String
        init(_ value: String) {
            self.value = value
        }
        
        static let current: AuthToken = .init(
            {
                guard let token = Bundle.main.object(forInfoDictionaryKey: "ALAN_API_TOKEN") as? String,
                      !token.isEmpty else {
                    fatalError("ALAN_API_TOKEN이 Info.plist에 설정되지 않았습니다. Secrets.xcconfig의 TOKEN 값을 Info.plist에 추가해주세요.")
                }
                return token
            }()
        )
    }
    
    nonisolated
    struct ID: Sendable, Hashable {
        // MARK: core
        let value: URL
        fileprivate init(_ value: URL) {
            self.value = value
        }
    }
}
