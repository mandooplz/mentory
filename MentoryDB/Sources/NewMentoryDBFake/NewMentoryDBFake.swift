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
import Collections


// MARK: fake
@MainActor
public final class NewMentoryDBFake: NewMentoryDBInterface {
    // MARK: core
    private let logger = Logger()
    
    public init() {
        
    }

    
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

    internal var _records: [NewDailyRecordFake] = []
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
    public func isSameDayRecordExist(for date: MentoryDate) -> Bool {
        self._records.contains { record in
            record.recordDate.isSameDate(as: date)
        }
    }

    internal var recordCreationQueue: Deque<RecordSnapshot> = []
    public func registerRecordSnapshot(_ recordData: RecordSnapshot) {
        self.recordCreationQueue.append(recordData)
    }



    // MARK: action
    public func createDailyRecords() async {
        // recordCreationQueue에서 RecordSnapshot을 하나 꺼내옴
        // 이를 통해 NewDailyRecordFake름 만듬
        while let snapshot = recordCreationQueue.popFirst() {
            let newRecord = NewDailyRecordFake(
                id: snapshot.objectID,
                owner: self,
                recordID: snapshot.recordID,
                recordDate: snapshot.recordDate,
                createAt: snapshot.createdAt,
                analyzedContent: snapshot.analyzedResult,
                emotion: snapshot.emotion
            )
            
            self._records.append(newRecord)
        }
    }
}
