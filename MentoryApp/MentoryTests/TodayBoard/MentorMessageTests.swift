//
//  MentorMessageTests.swift
//  Mentory
//
//  Created by 김민우 on 12/3/25.
//
import Foundation
import Testing
import Values
@testable import MentoryCore
import NewMentoryDBCore


// MARK: Tests
@Suite
struct MentorMessageTests {
    struct UpdateContent {
        let mentory: Mentory
        let mentorMessage: MentorMessage
        let mentoryDB: any NewMentoryDBInterface
        init() async throws {
            self.mentory = await Mentory()
            self.mentorMessage = try await getMentorMessage(mentory)
            self.mentoryDB = mentory.newMentoryDB
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
        
        @Test func setContent() async throws {
            // given
            try await setRandomCharacter(mentorMessage)
            
            try await #require(mentorMessage.content == nil)
            
            // when
            await mentorMessage.updateContent()
            
            // then
            await #expect(mentorMessage.content != nil)
        }
        @Test func setRecentUpdate() async throws {
            // given
            try await setRandomCharacter(mentorMessage)
            
            try await #require(mentorMessage.recentUpdate == nil)
            
            // when
            await mentorMessage.updateContent()
            
            // then
            await #expect(mentorMessage.recentUpdate != nil)
        }
        
        @Test func doNotUpdateContentIsSameDay() async throws {
            // given
            try await setRandomCharacter(mentorMessage)
            
            await mentorMessage.updateContent()
            
            await mentorMessage.resetContent()
            
            try await #require(mentorMessage.content == nil)
            try await #require(mentorMessage.recentUpdate != nil)
            
            // when
            await mentorMessage.updateContent()
            
            // then
            await #expect(mentorMessage.content == nil)
        }
        
        @Test func loadContentFromMentoryDB() async throws {
            // given
            try await setRandomCharacter(mentorMessage)
            
            await mentorMessage.updateContent()
            
            let recentUpdate = try #require(await mentorMessage.recentUpdate)
            let content = try #require(await mentorMessage.content)
            
            await MainActor.run {
                mentorMessage.recentUpdate = nil
                mentorMessage.content = nil
            }
            
            // when
            await mentorMessage.updateContent()
            
            // then
            await #expect(mentorMessage.content == content)
            await #expect(mentorMessage.recentUpdate != recentUpdate)
            
        }
    }
}


// MARK: Helpher
private func getMentorMessage(_ mentoryiOS: Mentory) async throws -> MentorMessage {
    await mentoryiOS.setUp()
    
    // create Onboarding
    await mentoryiOS.setUp()
    
    let onboarding = try #require(await mentoryiOS.onboarding)
    
    // create TodayBoard
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    
    await onboarding.submitForm()
    
    let todayBoard = try #require(await mentoryiOS.todayBoard)
    
    // create MentorMessage
    await todayBoard.setUpMentorMessage()
    
    let mentorMessage = try #require(await todayBoard.mentorMessage)
    
    return mentorMessage
}

private func setRandomCharacter(_ mentorMessage: MentorMessage) async throws {
    try await #require(mentorMessage.character == nil)
    
    await mentorMessage.setCharacterOnce(to: .random)
    
    try await #require(mentorMessage.character != nil)
}
