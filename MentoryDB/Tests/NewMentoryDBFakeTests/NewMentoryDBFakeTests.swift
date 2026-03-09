import Foundation
import Testing
import Values
@testable import NewMentoryDBFake

@MainActor
@Suite("NewMentoryDBFake")
struct NewMentoryDBFakeTests {
    @Test func defaultsAreEmpty() {
        let db = NewMentoryDBFake()

        #expect(db.name == nil)
        #expect(db.character == nil)
        #expect(db.mentorMessage == nil)
        #expect(db.records.isEmpty)
        #expect(db.recordCount == 0)
        #expect(db.recentRecord == nil)
        #expect(db.completedSuggestionCount == 0)
    }

    @Test func setNameUpdatesState() {
        let db = NewMentoryDBFake()

        db.setName("테스트 사용자")

        #expect(db.name == "테스트 사용자")
    }

    @Test func setCharacterUpdatesState() {
        let db = NewMentoryDBFake()

        db.setCharacter(.cool)

        #expect(db.character == .cool)
    }

    @Test func setMentorMessageUpdatesState() {
        let db = NewMentoryDBFake()
        let message = MessageData(
            createdAt: .now,
            content: "테스트 메시지",
            characterType: .cool
        )

        db.setMentorMessage(message)

        #expect(db.mentorMessage == message)
    }

    @Test func recordsExposeSnapshotsAndCount() {
        let db = NewMentoryDBFake()
        let olderRecord = makeRecord(
            owner: db,
            recordDate: .now.dayBefore(),
            analyzedContent: "이전 기록",
            emotion: .neutral
        )
        let newerRecord = makeRecord(
            owner: db,
            recordDate: .now,
            analyzedContent: "최신 기록",
            emotion: .pleasant
        )

        db.seedRecords([olderRecord, newerRecord])

        let records = db.records

        #expect(records.count == 2)
        #expect(records[0].objectID == olderRecord.id)
        #expect(records[0].analyzedResult == "이전 기록")
        #expect(records[1].objectID == newerRecord.id)
        #expect(records[1].emotion == .pleasant)
        #expect(db.recordCount == 2)
    }

    @Test func recentRecordReturnsLatestByDate() {
        let db = NewMentoryDBFake()
        let olderRecord = makeRecord(
            owner: db,
            recordDate: .now.dayBefore(),
            analyzedContent: "이전 기록",
            emotion: .neutral
        )
        let newerRecord = makeRecord(
            owner: db,
            recordDate: .now,
            analyzedContent: "최신 기록",
            emotion: .pleasant
        )

        db.seedRecords([olderRecord, newerRecord])

        let recentRecord = db.recentRecord

        #expect(recentRecord?.id == newerRecord.id)
    }
}

@MainActor
private func makeRecord(
    owner: NewMentoryDBFake,
    recordDate: MentoryDate,
    analyzedContent: String,
    emotion: Emotion
) -> NewDailyRecordFake {
    NewDailyRecordFake(
        id: UUID(),
        owner: owner,
        recordID: UUID(),
        ticketID: UUID(),
        recordDate: recordDate,
        createAt: recordDate,
        analyzedContent: analyzedContent,
        emotion: emotion
    )
}
