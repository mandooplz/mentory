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


        // process
        let answer: AlanLLM.Answer
        do {
            let question = AlanLLM.Question(textInput)
            answer = try await alanLLM.question(question)


        } catch {
            logger.error("\(error)")
            return
        }

        // mutate
        self.analyzedResult = answer.content
        self.mindType = .unPleasant
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
    
    enum MindType: String, Sendable {
        case veryUnpleasant
        case unPleasant
        case slightlyUnpleasant
        case neutral
        case slightlyPleasant
        case pleasant
        case veryPleasant
    }
}
