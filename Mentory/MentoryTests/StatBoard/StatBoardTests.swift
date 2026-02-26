//
//  StatBoardTests.swift
//  Mentory
//
//  Created by 김민우 on 2/25/26.
//
import Foundation
import Testing
@testable import Mentory


// MARK: Tests
@Suite("StatBoard")
struct StatBoardTests {
    struct Init {
        let mentoryiOS: MentoryiOS
        let statBoard: StatBoard
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.statBoard = try await getStatBoardForTest(mentoryiOS)
        }
        
        @Test func isAllRecordsEmpty() async {
            await #expect(statBoard.allRecords.isEmpty)
        }
    }
    
    struct LoadRecords {
        let mentoryiOS: MentoryiOS
        let statBoard: StatBoard
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.statBoard = try await getStatBoardForTest(mentoryiOS)
        }
        
        @Test func updateAllRecords() async throws {
            // given
            try await #require(statBoard.allRecords.isEmpty == true)
            
            // when
            await statBoard.loadRecords()
            
            // then
            await #expect(statBoard.allRecords.isEmpty == false)
        }
    }
}


// MARK: Helpher
private func getStatBoardForTest(_ mentoryiOS: MentoryiOS) async throws -> StatBoard {
    // create Onboarding
    await mentoryiOS.setUp()
    
    let onboarding = try #require(await mentoryiOS.onboarding)
    
    // create StatBoard
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    
    await onboarding.next()
    
    // return StatBoard
    let statBoard = try #require(await mentoryiOS.statBoard)
    
    return statBoard
}
