//
//  TodayBoardTests.swift
//  Mentory
//
//  Created by SJS on 11/14/25.
//

import Testing
import Foundation
import Values
@testable import Mentory


// MARK: Tests
@Suite("TodayBoard")
struct TodayBoardTests {
    struct LoadTodayRecords {
        let mentory: MentoryiOS
        let todayBoard: TodayBoard
        let mentoryDB: any MentoryDBInterface
        init() async throws {
            self.mentory = await MentoryiOS()
            self.todayBoard = try await getTodayBoardForTest(mentory)
            self.mentoryDB = mentory.mentoryDB
        }
        
        @Test func updateRecords() async throws {
            // given
            let recordData = RecordData(id: .init(),
                                        recordDate: .now,
                                        createdAt: .now,
                                        analyzedResult: "SAMPLE_RESULT",
                                        emotion: .neutral)
            
            try await mentoryDB.saveRecord(recordData)
            
            try await #require(todayBoard.records.count == 0)
            
            // when
            await todayBoard.loadTodayRecords()
            
            // then
            await #expect(todayBoard.records.count == 1)
        }
    }
}


// MARK: Helphers
private func getTodayBoardForTest(_ mentoryiOS: MentoryiOS) async throws -> TodayBoard {
    
    await mentoryiOS.setUp()
    
    // 온보딩 가져오기
    guard let onboarding = await mentoryiOS.onboarding else {
        throw NSError(domain: "Onboarding not initialized", code: -1)
    }
    
    // 온보딩 값 입력 + 검증
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    
    // 온보딩 완료
    await onboarding.next()
    
    // TodayBoard 가져오기
    guard let todayBoard = await mentoryiOS.todayBoard else {
        throw NSError(domain: "TodayBoard not initialized", code: -1)
    }
    
    return todayBoard
}
