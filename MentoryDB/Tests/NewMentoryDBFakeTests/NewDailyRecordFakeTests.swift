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
        
        init() async throws {
            self.mentoryDBFake = await NewMentoryDBFake()
            self.dailyRecordFake = try await getDailyRecordFakeForTests(mentoryDBFake)
        }
        
        @Test func clearSuggestionQueue() async throws {
            // given
            
            
            // when
            
            // then
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
