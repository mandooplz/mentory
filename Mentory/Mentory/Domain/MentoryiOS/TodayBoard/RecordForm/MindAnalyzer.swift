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

    // 분석 결과
    @Published var firstAnalysisResult: FirstAnalysisResult? = nil
    @Published var secondAnalysisResult: SecondAnalysisResult? = nil
    
    
    // MARK: action
    func startAnalyzing() async {
        // capture
        guard let textInput = owner?.textInput else {
            logger.error("TextInput이 비어있습니다.")
            return
        }

        guard textInput.isEmpty == false else {
            logger.error("textInput이 비어있습니다.")
            return
        }

        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        let mentoryiOS = todayBoard.owner!
        let alanLLM = mentoryiOS.alanLLM

        // MARK: 1차 분석 - 위험도, 주제, mindtype 분류
        logger.info("1차 분석 시작")
        let firstResult: FirstAnalysisResult
        do {
            let firstPrompt = """
            당신은 감정일기 분석을 위한 1차 스크리너입니다.
            반드시 한국어 입력을 분석해 다음 세 가지 필드를 가진 JSON만 반환해야 합니다.

            {
                "riskLevel": "low | medium | high",
                "topic": "텍스트 기반 핵심 주제 한 가지",
                "mindType": "veryUnpleasant | unPleasant | slightlyUnpleasant | neutral | slightlyPleasant | pleasant | veryPleasant"
            }

            규칙:
            1. JSON 이외의 어떤 문장도 출력하지 않는다.
            2. riskLevel 은 감정적 긴장도·위험 표현·부정성 강도를 보고 판단한다.
            3. topic 은 일기에서 가장 중심이 되는 주제 한 가지를 명사구로 추출한다. (예: 학업 스트레스, 직장 대인관계, 가족 갈등, 건강 불안, 자기비난 등)
            4. mindType 은 전체 정서의 쾌·불쾌 정도를 평가한다.
            5. 판단 근거를 설명하지 않는다. JSON만 출력한다.
            6. JSON 구조와 키 이름을 절대 변경하지 않는다.

            원본 일기: \(textInput)
            """
            let firstQuestion = AlanLLM.Question(firstPrompt)
            let firstAnswer = try await alanLLM.question(firstQuestion)

            // JSON 파싱
            guard let jsonData = firstAnswer.content.data(using: .utf8) else {
                logger.error("1차 분석 결과를 Data로 변환 실패")
                return
            }

            let decoder = JSONDecoder()
            firstResult = try decoder.decode(FirstAnalysisResult.self, from: jsonData)

            logger.info("1차 분석 완료 - 위험도: \(firstResult.riskLevel.rawValue), 주제: \(firstResult.topic), mindType: \(firstResult.mindType.rawValue)")
        } catch {
            logger.error("1차 분석 실패: \(error)")
            return
        }

        // MARK: 2차 분석 - 공감 메시지, 행동 추천 키워드
        logger.info("2차 분석 시작")
        let secondResult: SecondAnalysisResult
        do {
            // 1차 결과를 포함한 프롬프트 생성
            let secondPrompt = """
            주제: \(firstResult.topic)
            위험도: \(firstResult.riskLevel.rawValue)
            감정 상태: \(firstResult.mindType.rawValue)

            당신은 감정일기 1차 분석 결과와 원본 일기를 기반으로 공감 메시지와 간단한 행동 제안을 생성하는 코치입니다.

            출력 규칙:
            1. 반드시 아래 형식을 가진 JSON만 반환한다.
            2. JSON 외의 문장은 절대 출력하지 않는다.

            JSON 구조:
            {
                "empathyMessage": "<사용자의 상황과 감정에 대한 공감과 정서적 지지 문장>",
                "actionKeywords": ["행동1", "행동2", "행동3"]
            }

            생성 규칙:
            - empathyMessage는 1~3문장 정도의 짧고 직접적인 공감/정서적 지지여야 한다.
            - 상담/의학/진단/치료 조언 금지.  
            - 사용자의 감정 강도에 맞춰 자연스럽고 가볍게 위로/수용 중심으로 작성한다.
            - actionKeywords는 사용자가 바로 시도할 수 있는 구체적이지만 부담 없는 행동 2~4개를 제시한다.
            - 행동은 ‘얕은 단계’여야 한다: (예: 가벼운 산책, 물 한 컵 마시기, 잠깐 스트레칭, 방 정리 5분)
            - 주제 / 위험도 / 감정 상태는 공감문 생성의 참고용이지만 그대로 반복해서 인용하지 않는다.

            원본 일기:
            \(textInput)
            """

            let secondQuestion = AlanLLM.Question(secondPrompt)
            let secondAnswer = try await alanLLM.question(secondQuestion)

            // JSON 파싱
            guard let jsonData = secondAnswer.content.data(using: .utf8) else {
                logger.error("2차 분석 결과를 Data로 변환 실패")
                return
            }

            let decoder = JSONDecoder()
            secondResult = try decoder.decode(SecondAnalysisResult.self, from: jsonData)

            logger.info("2차 분석 완료 - 공감 메시지 길이: \(secondResult.empathyMessage.count)자, 추천 키워드 수: \(secondResult.actionKeywords.count)개")
        } catch {
            logger.error("2차 분석 실패: \(error)")
            return
        }

        // MARK: 결과 저장
        self.firstAnalysisResult = firstResult
        self.secondAnalysisResult = secondResult
        self.mindType = firstResult.mindType
        self.analyzedResult = secondResult.empathyMessage

        logger.info("분석 완료")
    }

    func saveRecord() async {
        // capture
        guard let recordForm = owner else {
            logger.error("RecordForm owner가 없습니다.")
            return
        }
        guard let todayBoard = recordForm.owner else {
            logger.error("TodayBoard owner가 없습니다.")
            return
        }
        guard let repository = todayBoard.recordRepository else {
            logger.error("RecordRepository가 설정되지 않았습니다.")
            return
        }

        // MentoryRecord 생성
        let record = MentoryRecord(
            recordDate: Date(),
            analyzedContent: self.analyzedResult,
            emotionType: self.mindType?.rawValue,
            completionTimeInSeconds: recordForm.completionTime
        )

        // process
        do {
            try await repository.save(record)
            logger.info("레코드 저장 성공: \(record.id)")

            // 저장 후 오늘의 레코드 다시 로드
            await todayBoard.loadTodayRecords()
        } catch {
            logger.error("레코드 저장 실패: \(error)")
        }
    }
    
    
    // MARK: value
    enum CharacterType: Sendable {
        case A
        case B
    }

    enum MindType: String, Sendable, Codable {
        case veryUnpleasant
        case unPleasant
        case slightlyUnpleasant
        case neutral
        case slightlyPleasant
        case pleasant
        case veryPleasant
    }

    enum RiskLevel: String, Sendable, Codable {
        case low
        case medium
        case high
    }

    // 1차 분석 결과
    struct FirstAnalysisResult: Sendable, Codable {
        let riskLevel: RiskLevel
        let topic: String
        let mindType: MindType
    }

    // 2차 분석 결과
    struct SecondAnalysisResult: Sendable, Codable {
        let empathyMessage: String
        let actionKeywords: [String]
    }
}
