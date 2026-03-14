//
//  MentoryTests.swift
//  MentoryTests
//
//  Created by 김민우 on 11/13/25.
//
import Testing
@testable import MentoryCore
import NewMentoryDBCore


// MARK: Tests
@Suite("Mentory", .timeLimit(.minutes(1)))
struct MentoryTests {
    struct Init {
        let mentory: Mentory
        init() async throws {
            self.mentory = await Mentory()
        }
        
        @Test func onboardingShouldBeNilOnInit() async throws {
            await #expect(mentory.onboarding == nil)
        }
        @Test func statBoardShouldBeNilOnInit() async throws {
            await #expect(mentory.statBoard == nil)
        }
    }

    struct SetUp {
        let mentory: Mentory
        init() async throws {
            self.mentory = await Mentory()
        }
        
        @Test func createOnboarding() async throws {
            // given
            try await #require(mentory.onboarding == nil)
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.onboarding != nil)
        }
        @Test func keepStatBoardNil() async throws {
            // given
            try await #require(mentory.statBoard == nil)
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.statBoard == nil)
        }

        
        @Test func doNothingWhenUserNameAlreadySet() async throws {
            // given
            await MainActor.run {
                mentory.userName = "TEST_USERNAME"
            }
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.onboarding == nil)
        }
        @Test func keepExistingOnboarding_WhenOnboardingAlreadyExists() async throws {
            // given
            let testOnboarding = await Onboarding(owner: mentory)
            await MainActor.run {
                mentory.onboarding = testOnboarding
            }
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.onboarding?.objectID == testOnboarding.objectID)
        }
        @Test func doNothingWhenOnboardingAlreadyFinished() async throws {
            // given
            let testOnboarding = await Onboarding(owner: mentory)
            await MainActor.run {
                mentory.isOnboardingFinished = true
                mentory.onboarding = testOnboarding
            }
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.onboarding?.objectID == testOnboarding.objectID)
        }
    }
    
    struct LoadUserName {
        let mentory: Mentory
        let mentoryDB: any NewMentoryDBInterface
        init() async throws {
            self.mentory = await Mentory()
            self.mentoryDB = mentory.newMentoryDB
        }
        
        @Test func keepOnboardingNil() async throws {
            // given
            await mentoryDB.setName("TEST_USER_NAME")
            
            // when
            await mentory.loadUserName()
            
            // then
            await #expect(mentory.onboarding == nil)
        }
        @Test func setOnboardingFinishedTrue() async throws {
            // given
            await mentoryDB.setName("TEST_USER_NAME")
            
            try await #require(mentory.isOnboardingFinished == false)
            
            // when
            await mentory.loadUserName()
            
            // then
            await #expect(mentory.isOnboardingFinished == true)
        }
        
        @Test func createSettingBoard() async throws {
            // given
            await mentoryDB.setName("TEST_USER_NAME")
            
            try await #require(mentory.settingBoard == nil)
            
            // when
            await mentory.loadUserName()
            
            // then
            await #expect(mentory.settingBoard != nil)
        }
        @Test func createStatBoard() async throws {
            // given
            await mentoryDB.setName("TEST_USER_NAME")

            try await #require(mentory.statBoard == nil)

            // when
            await mentory.loadUserName()

            // then
            await #expect(mentory.statBoard != nil)
        }
    }
}


// MARK: Helpher
