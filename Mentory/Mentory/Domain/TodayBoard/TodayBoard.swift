//
//  TodayBoard.swift
//  Mentory
//
//  Created by SJS, 구현모 on 11/14/25.
//
import Foundation
import Combine
import Values
import OSLog


// MARK: Object
@MainActor
final class TodayBoard: Sendable, ObservableObject {
    // MARK: core
    nonisolated private let logger = Logger(subsystem: "MentoryiOS.TodayBoard", category: "Domain")
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: MentoryiOS?
    
    @Published var mentorMessage: MentorMessage? = nil

    @Published var recordForms: [RecordForm] = []
    @Published var recordFormSelection: RecordForm? = nil
    func recentUpdatedate() -> MentoryDate? {
        guard self.recordForms.isEmpty == false else {
            return nil
        }
        
        return self.recordForms
            .map { $0.targetDate }
            .max()!
    }
    
    
    private(set) var currentDate: MentoryDate = .now
    func setCurrentDate(_ newDate: MentoryDate) {
        guard newDate > currentDate else {
            logger.error("이전 날짜로 설정하려고 했습니다.")
            return
        }
        
        self.currentDate = newDate
    }
    func resetCurrentDate() {
        self.currentDate = .now
    }
    
    @Published var recordCount: Int? = nil
    
    @Published var suggestions: [Suggestion] = []
    
    
    // MARK: action
    func setUpMentorMessage() async {
        // capture
        guard self.mentorMessage == nil else {
            logger.error("이미 MentorMessage 객체가 존재합니다.")
            return
        }
        
        // mutate
        self.mentorMessage = MentorMessage(owner: self)
    }
    
    func setUpRecordForms() async {
        // capture
        guard self.recordForms.isEmpty == true else {
            logger.error("이미 recordForms 배열 안에 객체들이 존재합니다.")
            return
        }
        let now = MentoryDate.now

        // process
        let today = now
        let yesterday = today.dayBefore()
        let twoDaysAgo = today.twoDaysBefore()
        
        let dates = [today, yesterday, twoDaysAgo]

        
        // mutate
        let recordForms = dates.map { date in
            RecordForm(owner: self, targetDate: date)
        }
        self.recordForms = recordForms
    }
    func updateRecordForms() async {
        // capture
        let currentDate = self.currentDate
        let recordForms = self.recordForms
        guard recordForms.isEmpty == false else {
            logger.error("recordForms가 비어 있어 updateRecordForms을 취소합니다.")
            return
        }
        guard let recentUpdatedate = self.recentUpdatedate() else {
            logger.error("recentUpdateDate가 nil이어서 updateRecordForms을 취소합니다.")
            return
        }
        
        // process
        let isSameDay = recentUpdatedate.isSameDate(as: currentDate)
        guard isSameDay == false else {
            logger.error("현재 날짜와 가장 최근 업데이트된 날짜가 같습니다. 아무것도 하지 않습니다.")
            return
        }
        
        let targetDates: [MentoryDate] = [
            currentDate,
            currentDate.dayBefore(),
            currentDate.twoDaysBefore()
        ]
        
        var newRecordForms: [RecordForm] = []
        for targetDate in targetDates {
            if let existing = recordForms.first(where: { $0.targetDate.isSameDate(as: targetDate) }) {
                    newRecordForms.append(existing)
            } else {
                let newForm = RecordForm(owner: self, targetDate: targetDate)
                newRecordForms.append(newForm)
            }
        }
        newRecordForms.sort { $0.targetDate < $1.targetDate }
            
        // mutate
        self.recordForms = newRecordForms
    }
    
    func setUpSuggestions() async {
        // capture
        
        // process
        
        // mutate
        fatalError("구현 예정")
    }
    
    func fetchUserRecordCoount() async {
        // capture
        let mentoryiOS = self.owner!
        let mentoryDB = mentoryiOS.mentoryDB
        
        // process
        let recordCount: Int
        do {
            async let count = try await mentoryDB.getRecordCount()
            recordCount = try await count
        } catch {
            logger.error("\(error)")
            return
        }
        
        // mutate
        self.recordCount = recordCount
    }
}
