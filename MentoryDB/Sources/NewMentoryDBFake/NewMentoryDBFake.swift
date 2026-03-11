//
//  NewMentoryDBFake.swift
//  MentoryDB
//
//  Created by 김민우 on 3/4/26.
//
import NewMentoryDBCore
import Values
import Foundation
import OSLog


// MARK: fake
@MainActor
public final class NewMentoryDBFake: NewMentoryDBInterface {
    // MARK: core
    private let logger = Logger()

    
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
            .sorted(by: { $0.recordDate > $1.recordDate })
            .map {
                RecordSnapshot(
                    objectID: $0.id,
                    recordDate: $0.recordDate,
                    createdAt: $0.createAt,
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
    public func getRecord(recordID: UUID) async -> NewDailyRecordFake? {
        self._records.first(where: { $0.recordID == recordID })
    }
    public func isSameDayRecordExist(for date: Values.MentoryDate) -> Bool {
        self._records.contains { record in
            record.recordDate.isSameDate(as: date)
        }
    }

    internal var recordCreationQueue: [RecordSnapshot] = []
    public func insertTicket(_ recordData: RecordSnapshot) {
        self.recordCreationQueue.append(recordData)
    }



    // MARK: action
    public func createDailyRecords() async {
        fatalError()
    }
}
