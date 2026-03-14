import Combine
//
//  TodayBoard.swift
//  Mentory
//
//  Created by SJS, 구현모 on 11/14/25.
//
import Foundation
import NewMentoryDBCore
import OSLog
import Values

// MARK: Object
@MainActor
public final class TodayBoard: Sendable, ObservableObject {
    // MARK: core
    nonisolated private let logger = Logger()

    public init(owner: Mentory) {
        self.owner = owner
    }

    // MARK: state
    public nonisolated let objectID = ObjectID.random
    public weak var owner: Mentory?

    @Published public var mentorMessage: MentorMessage? = nil

    @Published public var recordForms: [RecordForm] = []
    public func areAllRecordFormsDisabled() -> Bool {
        return self.recordForms.allSatisfy(\.isDisabled)
    }
    @Published public var recordFormSelection: RecordForm? = nil
    public func recentUpdatedate() -> MentoryDate? {
        guard self.recordForms.isEmpty == false else {
            return nil
        }

        return self.recordForms
            .map { $0.targetDate }
            .max()!
    }

    public private(set) var currentDate: MentoryDate = .now
    public func setCurrentDate(_ newDate: MentoryDate) {
        guard newDate > currentDate else {
            logger.error("이전 날짜로 설정하려고 했습니다.")
            return
        }

        self.currentDate = newDate
    }
    public func refreshCurrentDate() {
        self.currentDate = .now
    }

    @Published public var recordCount: Int? = nil

    @Published public var suggestions: [Suggestion] = []
    public var recentSuggestionUpdate: MentoryDate? = nil
    public func getSuggestionIndicator() -> String {
        let totalCount = self.suggestions
            .count

        let doneCount = self.suggestions
            .filter { $0.isDone == true }
            .count

        return "\(doneCount)/\(totalCount)"
    }
    public var suggestionProgress: Double {
        guard suggestions.count > 0 else { return 0 }
        return Double(suggestions.filter { $0.isDone }.count) / Double(suggestions.count)
    }
    @Published public var completedSuggestionsCount: Int = 0
    @Published public var earnedBadges: [BadgeType] = []

    // MARK: action
    public func setUpMentorMessage() async {
        // capture
        guard self.mentorMessage == nil else {
            logger.error("이미 MentorMessage 객체가 존재합니다.")
            return
        }

        // mutate
        let mentorMessage = MentorMessage(owner: self)
        let preferredCharacter = await self.owner?.newMentoryDB.character ?? .warm
        mentorMessage.setCharacterOnce(to: preferredCharacter)
        self.mentorMessage = mentorMessage
        logger.debug("mentorMessage 객체가 생성되었습니다.")
    }

    public func setUpRecordForms() async {
        // capture
        guard self.recordForms.isEmpty == true else {
            logger.error("이미 recordForms 배열 안에 객체들이 존재합니다.\(self.recordForms.count)")
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
            RecordForm(
                owner: self,
                targetDate: date
            )
        }
        self.recordForms = recordForms
        logger.debug("recordForms 배열이 생성되었습니다.\(recordForms)")
    }
    public func updateRecordForms() async {
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
            currentDate.twoDaysBefore(),
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

    public func loadSuggestions() async {
        // capture
        let currentDate = self.currentDate

        let mentoryiOS = self.owner!
        let newMentoryDB = mentoryiOS.newMentoryDB

        // process - MentoryDB에서 DailyRecord 가져오기
        guard let recentRecord = await newMentoryDB.recentRecord else {
            logger.error("MentoryDB 안에 최근 Record가 존재하지 않습니다.")
            return
        }
        logger.debug("NewMentoryDB에서 최근 DailyRecord를 가져왔습니다.")

        // process - MentoryDB에서 Suggestion 가져오기
        let recordID = await recentRecord.recordID
        let suggestionDatas = await recentRecord.suggestionSnapshots

        // mutate
        self.suggestions =
            suggestionDatas
            .map {
                Suggestion(
                    owner: self,
                    parentRecord: recordID,
                    suggestionID: $0.suggestionID,
                    content: $0.content,
                    isDone: $0.isDone
                )
            }

        self.recentSuggestionUpdate = currentDate
        logger.debug("추천행동가져오기\(suggestionDatas)")
    }

    public func fetchUserRecordCount() async {
        // capture
        let mentoryiOS = self.owner!
        let newMentoryDB = mentoryiOS.newMentoryDB

        // process
        let recordCount = await newMentoryDB.recordCount

        // mutate
        self.recordCount = recordCount
    }
    
    
    // MARK: value
    public nonisolated struct ObjectID: ObjectIdentifier {
        public let id: UUID
        public init(id: UUID) {
            self.id = id
        }
    }
}
