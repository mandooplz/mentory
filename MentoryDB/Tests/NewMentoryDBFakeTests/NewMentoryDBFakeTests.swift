import Foundation
import Testing
import Values
@testable import NewMentoryDBFake


@Suite("NewMentoryDBFake")
struct NewMentoryDBFakeTests {
    struct CreateDailyRecords {
        let newMentoryDBFake: NewMentoryDBFake
        let testSnapshot: RecordSnapshot
        init() async {
            self.newMentoryDBFake = await NewMentoryDBFake()
            
            self.testSnapshot = RecordSnapshot(
                objectID: .init(),
                recordID: .random,
                recordDate: .now,
                createdAt: .now,
                analyzedResult: "TEST_RESULT",
                emotion: .neutral
            )
        }
        
        @Test func setIDWithObjectID() async throws {
            // given
            await newMentoryDBFake.registerRecordSnapshot(testSnapshot)
            
            try await #require(newMentoryDBFake.recordCreationQueue.count == 1)
            
            // when
            await newMentoryDBFake.createDailyRecords()
            
            // then
            let newDailyRecordFake = try #require(await newMentoryDBFake._records.first)
            
            #expect(newDailyRecordFake.objectID == testSnapshot.objectID)
        }
        @Test func setRecordIDWithRecordID() async throws {
            // given
            await newMentoryDBFake.registerRecordSnapshot(testSnapshot)
            
            try await #require(newMentoryDBFake.recordCreationQueue.count == 1)
            
            // when
            await newMentoryDBFake.createDailyRecords()
            
            // then
            let newDailyRecordFake = try #require(await newMentoryDBFake._records.first)
            
            await #expect(newDailyRecordFake.recordID == testSnapshot.recordID)
        }
        
        @Test func clearRecordCreationQueue() async throws {
            // given
            await newMentoryDBFake.registerRecordSnapshot(testSnapshot)
            
            try await #require(newMentoryDBFake.recordCreationQueue.isEmpty == false)
            
            // when
            await newMentoryDBFake.createDailyRecords()
            
            // then
            await #expect(newMentoryDBFake.recordCreationQueue.isEmpty == true)
        }
        @Test func createRecords() async throws {
            // given
            try await #require(newMentoryDBFake._records.isEmpty == true)
            try await #require(newMentoryDBFake.recordCreationQueue.count == 0)
            
            await newMentoryDBFake.registerRecordSnapshot(testSnapshot)
            
            try await #require(newMentoryDBFake.recordCreationQueue.count == 1)
            
            
            // when
            await newMentoryDBFake.createDailyRecords()
            
            // then
            await #expect(newMentoryDBFake._records.isEmpty == false)
        }
    }
}

