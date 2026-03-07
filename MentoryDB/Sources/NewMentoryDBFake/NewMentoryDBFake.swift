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
public actor NewMentoryDBFake: NewMentoryDBInterface {
    // MARK: core


    // MARK: state
    public var name: String? = nil
    public var character: Values.MentoryCharacter? = nil
    public var mentorMessage: Values.MessageData?

    public var records: [Values.RecordData] = []
    public var recordCount: Int {
        self.records.count
    }
    public var recentRecord: NewDailyRecordFake? {
        fatalError()
    }

    public func getRecord(ticketId: UUID) -> NewDailyRecordFake? {
        fatalError()
    }
    public func isSameDayRecordExist(for date: Values.MentoryDate) -> Bool {
        fatalError()
    }

    public var completedSuggestionCount: Int = 0

    public func updateSuggestionStatus(targetId: UUID, isDone: Bool) {
        fatalError()
    }

    public func insertTicket(_ recordData: Values.RecordData) {
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
