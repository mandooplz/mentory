import Foundation
import Testing
import Values
@testable import NewMentoryDBFake


@Suite("NewMentoryDBFake")
struct NewMentoryDBFakeTests {
    struct CreateDailyRecords {
        let newMentoryDBFake: NewMentoryDBFake
        init() async {
            self.newMentoryDBFake = await NewMentoryDBFake()
        }
        
        @Test func clearRecordCreationQueue() async throws {
            // given
            let testSnapshot = RecordSnapshot(
                recordDate: .now,
                analyzedResult: "TEST_RESULT",
                emotion: .neutral)
            
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
            
            let testSnapshot = RecordSnapshot(
                recordDate: .now,
                analyzedResult: "TEST_RESULT",
                emotion: .neutral)
            
            await newMentoryDBFake.registerRecordSnapshot(testSnapshot)
            
            try await #require(newMentoryDBFake.recordCreationQueue.count == 1)
            
            
            // when
            await newMentoryDBFake.createDailyRecords()
            
            // then
            await #expect(newMentoryDBFake._records.isEmpty == false)
        }
    }
}

