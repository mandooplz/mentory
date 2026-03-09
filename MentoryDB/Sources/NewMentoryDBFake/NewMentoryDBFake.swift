//
//  NewMentoryDBFake.swift
//  MentoryDB
//
//  Created by 김민우 on 3/4/26.
//
import NewMentoryDBCore
import Values
import Foundation


// MARK: fake
@MainActor
public final class NewMentoryDBFake: NewMentoryDBInterface {
    // MARK: core


    // MARK: state
    public nonisolated let id: UUID = UUID()

    public var name: String? = nil
    public func setName(_ newValue: String) {
        self.name = newValue
    }

    public var character: Values.MentoryCharacter? = nil
    public func setCharacter(_ newValue: MentoryCharacter) {
        self.character = newValue
    }

    public var mentorMessage: MessageData?
    public func setMentorMessage(_ newValue: MessageData) {
        self.mentorMessage = newValue
    }

    private var _records: [NewDailyRecordFake] = []
    public var records: [RecordSnapshot] {
        self._records
            .map {
                RecordSnapshot(
                    objectID: $0.id,
                    recordDate: $0.recordDate,
                    analyzedResult: $0.analyzedContent,
                    emotion: $0.emotion
                )
            }
    }
    public var recordCount: Int {
        self._records.count
    }
    public var recentRecord: NewDailyRecordFake? {
        return self._records
            .max(by: { $0.recordDate < $1.recordDate })
    }

    public func getRecord(ticketId: UUID) -> NewDailyRecordFake? {
        fatalError()
    }
    public func getRecord(recordID: UUID) async -> NewDailyRecordFake? {
        fatalError()
    }

    public func isSameDayRecordExist(for date: Values.MentoryDate) -> Bool {
        fatalError()
    }

    public var completedSuggestionCount: Int = 0

    func seedRecords(_ records: [NewDailyRecordFake]) {
        self._records = records
    }

    public func insertTicket(_ recordData: Values.RecordSnapshot) {
        fatalError()
    }

    public func insertSuggestions(ticketId: UUID, suggestions: [Values.SuggestionData]) async {
        fatalError()
    }


    // MARK: action
    public func createDailyRecords() async {
        fatalError()
    }


}
