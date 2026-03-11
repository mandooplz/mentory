//
//  NewDailyRecordFakeTests.swift
//  MentoryDB
//
//  Created by 김민우 on 3/12/26.
//

import Foundation
import Testing
import Values
@testable import NewMentoryDBFake


// MARK: Tests
@Suite("NewDailyRecordFake")
struct NewDailyRecordFakeTests {
    struct CreateDailySuggestions {
        let mentoryDBFake: NewMentoryDBFake
        let dailyRecordFake: NewDailyRecordFake
        let testSnapshot: SuggestionSnapshot
        
        init() async throws {
            self.mentoryDBFake = await NewMentoryDBFake()
            self.dailyRecordFake = try await getDailyRecordFakeForTests(mentoryDBFake)
            self.testSnapshot = SuggestionSnapshot(
                objectID: .init(),
                suggestionID: .random,
                parentRecord: .random,
                content: "TEST_CONTENT",
                isDone: false
            )
        }
        
        @Test func createDailySuggestion() async throws {
            
        }
        @Test func clearSuggestionQueue() async throws {
            // given
            await dailyRecordFake.registerSnapshots([testSnapshot])
            
            try await #require(dailyRecordFake.createSuggestionQueue.isEmpty == false)
            
            // when
            await dailyRecordFake.createDailySuggestions()
            
            
            // then
            await #expect(dailyRecordFake.createSuggestionQueue.isEmpty == true)
        }
    }
}


// MARK: Helpher
fileprivate func getDailyRecordFakeForTests(_ newMentoryDBFake: NewMentoryDBFake) async throws -> NewDailyRecordFake {
    let testSnapshot = RecordSnapshot(
        objectID: .init(),
        recordID: .random,
        recordDate: .now,
        createdAt: .now,
        analyzedResult: "TEST_ANALYZED_RESULT",
        emotion: .neutral
    )
    
    try await #require(newMentoryDBFake._records.count == 0)
    
    await newMentoryDBFake.registerRecordSnapshot(testSnapshot)
    await newMentoryDBFake.createDailyRecords()
    
    try await #require(newMentoryDBFake._records.count == 1)
    
    let dailyRecordFake = try #require(await newMentoryDBFake._records.first)
    
    return dailyRecordFake
}
