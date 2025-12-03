//
//  MentorMessageTests.swift
//  Mentory
//
//  Created by 김민우 on 12/3/25.
//
import Foundation
import Testing
import Values
@testable import Mentory


// MARK: Tests
@Suite
struct MentorMessageTests {
    struct FetchCharacter {
        let mentoryiOS: MentoryiOS
        let mentorMessage: MentorMessage
        let mentoryDB: any MentoryDBInterface
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.mentorMessage = try await getMentorMessage(mentoryiOS)
            self.mentoryDB = mentoryiOS.mentoryDB
        }
        
        @Test(arguments: MentoryCharacter.allCases)
        func setCharacterFromDB(_ character: MentoryCharacter) async throws {
            // given
            await MainActor.run {
                mentorMessage.character = character
            }
            
            // when
            await mentorMessage.fetchCharacter()
            
            // then
            await #expect(mentorMessage.character == character)
        }
        
        @Test func whenCharacterAlreadyFetched() async throws {
            // given
            await mentorMessage.fetchCharacter()
            
            let character = try #require(await mentorMessage.character)
            
            // when
            await mentorMessage.fetchCharacter()
            
            // then
            await #expect(mentorMessage.character == character)
        }
    }
    
    struct UpdateContent {
        let mentoryiOS: MentoryiOS
        let mentorMessage: MentorMessage
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.mentorMessage = try await getMentorMessage(mentoryiOS)
        }
        
        @Test func whenCharacterIsNil() async throws {
            // given
            try await #require(mentorMessage.character == nil)
            
            try await #require(mentorMessage.content == nil)
            
            // when
            await mentorMessage.updateContent()
            
            // then
            await #expect(mentorMessage.content == nil)
        }
    }
}


// MARK: Helpher
private func getMentorMessage(_ mentoryiOS: MentoryiOS) async throws -> MentorMessage {
    await mentoryiOS.setUp()
    
    // create Onboarding
    await mentoryiOS.setUp()
    
    let onboarding = try #require(await mentoryiOS.onboarding)
    
    // create TodayBoard
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    
    await onboarding.next()
    
    let todayBoard = try #require(await mentoryiOS.todayBoard)
    
    // create MentorMessage
    await todayBoard.setUpMentorMessage()
    
    let mentorMessage = try #require(await todayBoard.mentorMessage)
    
    return mentorMessage
}
