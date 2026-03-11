//
//  MindAnalyzer.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//
import Foundation
import Values
import Combine
import OSLog
import NewFirebaseLLM


// MARK: Object
@MainActor
public final class MindAnalyzer: Sendable, ObservableObject, Distinguishable {
    // MARK: core
    private nonisolated let logger = Logger()
    internal init(owner: RecordForm) {
        self.owner = owner
    }
    
    
    // MARK: state
    public nonisolated let id = UUID()
    public weak var owner: RecordForm?
    
    @Published public var status: Status = .ready
    @Published public var character: MentoryCharacter? = nil
    
    @Published public private(set) var analyzedResult: String? = nil
    @Published public private(set) var mindType: Emotion? = nil
    
    private(set) var currentDate: MentoryDate = .now
    public func refreshCurrentDate() {
        self.currentDate = .now
    }
    
    
    
    // MARK: action
    public func analyze() async {
        // capture
        guard let textInput = owner?.textInput else {
            logger.error("Owner?.textInput이 nil입니다.")
            return
        }

        guard textInput.isEmpty == false else {
            logger.error("textInput이 비어 있습니다.")
            return
        }
        
        guard let character else {
            logger.error("MindAnalyzer.character를 먼저 선택해야 합니다.")
            return
        }
        
        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        let mentoryiOS = todayBoard.owner!
        
        let firebaseLLM = mentoryiOS.newFirebaseLLM
        let newMentoryDB = mentoryiOS.newMentoryDB
        
        let targetDate = recordForm.targetDate
        
        // 이미지와 음성 입력 가져오기
        let imageInput = recordForm.imageInput
        let voiceInput = recordForm.voiceInput
        
        // 멀티모달 입력 로깅
        if imageInput != nil {
            logger.debug("이미지 첨부됨 - 감정 분석에 포함")
        }
        if voiceInput != nil {
            logger.debug("음성 첨부됨 - 감정 분석에 포함")
        }


        // process - Character 설정
        await newMentoryDB.setCharacter(character)


        // process - FirebaseLLM
        // 감정 분석 (텍스트 + 이미지 + 음성)
        let question = FirebaseQuestion(
            textInput,
            imageData: imageInput,
            voiceURL: voiceInput
        )
        
        await firebaseLLM.setQuestion(question)
        await firebaseLLM.setCharacter(character)
        
        await firebaseLLM.getAnalysis()
        
        guard let analysis = await firebaseLLM.analysis else {
            logger.error("FirebaseLLM 감정 분석 과정에서 오류가 발생했습니다.")
            return
        }
        logger.debug("멀티모달 감정 분석 완료")
        
        
        // process - MentoryDB
        // DailyRecord & DailySuggestion 생성
        let snapshot = RecordSnapshot(
            objectID: .init(),
            recordDate: targetDate,
            createdAt: .now,
            analyzedResult: analysis.empathyMessage,
            emotion: analysis.mindType
        )
        
        let suggestionDatas = analysis.actionKeywords
            .map { actionText in
                SuggestionData(
                    parentRecord: snapshot.recordID,
                    content: actionText
                )
            }

        await newMentoryDB.registerRecordSnapshot(snapshot)
        await newMentoryDB.createDailyRecords()
        
        guard let record = await newMentoryDB.getRecord(recordID: snapshot.recordID) else {
            logger.error("\(snapshot.objectID.uuidString.prefix(8))의 Record를 찾을 수 없습니다.")
            return
        }
        await record.addSuggestions(suggestionDatas)
        
        
        if mentoryiOS.statBoard == nil {
            mentoryiOS.statBoard = StatBoard(owner: mentoryiOS)
        }

        if let statBoard = mentoryiOS.statBoard {
            await statBoard.loadRecords()
        }

        logger.debug("MentoryDB에 RecordData와 SuggestionData를 저장했습니다.")


        // mutate
        self.mindType = analysis.mindType
        self.analyzedResult = analysis.empathyMessage
        self.status = .finished
    }
    
    public func updateSuggestions() async {
        // capture
        let currentDate = self.currentDate
        
        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        let mentoryiOS = todayBoard.owner!
        let newMentoryDB = mentoryiOS.newMentoryDB
        
        // process - 최근 Suggestions 데이터 조회
        guard let recentRecord = await newMentoryDB.recentRecord else {
            logger.error("MentoryDB 안에 최근 Record가 존재하지 않습니다.")
            return
        }
        
        let suggestionDatas = await recentRecord.suggestionDatas

        
        // mutate
        todayBoard.suggestions = suggestionDatas
            .map { Suggestion(
                owner: todayBoard,
                parentRecord: $0.parentRecord,
                target: $0.target,
                content: $0.content,
                isDone: $0.isDone
            )
            }
        
        todayBoard.recentSuggestionUpdate = currentDate
        logger.debug("추천행동가져오기\(suggestionDatas)")
    }
    public func finish() {
        //capture
        let recordForm = self.owner!
        let todayBoard = recordForm.owner!
        
        //mutate
        todayBoard.recordFormSelection = nil
        recordForm.mindAnalyzer = nil
    }
    
    
    // MARK: value
    public enum Status: Sendable, Hashable {
        // MARK: core
        case ready
        case analyzing
        case finished
        
        // MARK: operator
        public var isAnalyzing: Bool {
            self == .analyzing
        }
        
        public var isAnalyzeFinished: Bool {
            self == .finished
        }
        
        public var isSelectingStage: Bool {
            self == .ready
        }
    }
}
