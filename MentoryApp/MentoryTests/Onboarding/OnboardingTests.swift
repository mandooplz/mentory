//
//  OnboardingTests.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Testing
import Foundation
@testable import MentoryCore


// MARK: Tests
@Suite("Onboarding", .timeLimit(.minutes(1)))
struct OnboardingTests {
    struct ValidateInput {
        let mentory: Mentory
        let onboarding: Onboarding
        init() async throws {
            self.mentory = await Mentory()
            self.onboarding = try await getOnboardingForTest(mentory)
        }
        
        @Test func whenNameInputIsEmpty() async throws {
            // given
            try await #require(onboarding.nameInput.isEmpty)
            try await #require(onboarding.validationResult == .none)
            
            await #expect(onboarding.validationResult == .none)
            
            // when
            await onboarding.validateInput()
            
            // then
            await #expect(onboarding.validationResult == .nameInputIsEmpty)
        }
        @Test func resetResult_WhenNameInputIsEmpty() async throws {
            // given
            await MainActor.run {
                onboarding.validationResult = .nameInputIsEmpty
            }
            
            await onboarding.setName("TEST_USER_NAME")
            
            try await #require(onboarding.validationResult != .none)
            try await #require(onboarding.nameInput.isEmpty == false)
            
            // when
            await onboarding.validateInput()
            
            // then
            await #expect(onboarding.validationResult == .none)
        }
        @Test func whenNameInputIsNotEmpty() async throws {
            // given
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            
            try await #require(onboarding.validationResult == .none)
            
            // when
            await onboarding.validateInput()
            
            // then
            await #expect(onboarding.validationResult == .none)
        }
    }
        
    struct SubmitForm {
        let mentory: Mentory
        let onboarding: Onboarding
        init() async throws {
            self.mentory = await Mentory()
            self.onboarding = try await getOnboardingForTest(mentory)
        }
        
        @Test func whenNameInputIsEmpty() async throws {
            // given
            let onboardingFormMentory = try #require(await mentory.onboarding)
            try await #require(mentory.onboarding != nil)
            try await #require(mentory.onboardingFinished == false)
            try await #require(mentory.todayBoard == nil)
            try await #require(mentory.settingBoard == nil)
            
            // when
            await onboarding.submitForm()
            
            // then
            await #expect(mentory.onboarding?.id == onboardingFormMentory.id)
            await #expect(mentory.onboardingFinished == false)
            await #expect(mentory.todayBoard == nil)
            await #expect(mentory.settingBoard == nil)
        }
        @Test func whenIsUsedIsTrue() async throws {
            // given
            await onboarding.setName("TEST_USER_NAME")
            await onboarding.submitForm()
            
            try await #require(onboarding.isUsed == true)
            
            let oldTodayBoard = try #require(await mentory.todayBoard)
            let oldSettingBoard = try #require(await mentory.settingBoard)
            
            // when
            await onboarding.submitForm()
            
            // then
            await #expect(mentory.todayBoard?.id == oldTodayBoard.id)
            await #expect(mentory.settingBoard?.id == oldSettingBoard.id)
        }
        
        @Test func setIsUsedTrue() async throws {
            // given
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            
            try await #require(onboarding.isUsed == false)
            
            // when
            await onboarding.submitForm()
            
            // then
            await #expect(onboarding.isUsed == true)
        }
        
        @Test func Mentory_setUserName() async throws {
            // given
            try await #require(mentory.userName == nil)
            
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            try await #require(onboarding.nameInput.isEmpty == false)
            
            
            // when
            await onboarding.submitForm()
            
            // then
            await #expect(mentory.userName == testUserName)
        }
        
        @Test func Mentory_removeOnboarding() async throws {
            // given
            try await #require(mentory.onboarding != nil)
            
            await onboarding.setName("TEST_USER_NAME")
            
            // when
            await onboarding.submitForm()
            
            // then
            await #expect(mentory.onboarding == nil)
        }
        @Test func Mentory_setOnBoardingFinished() async throws {
            // given
            try await #require(mentory.onboardingFinished == false)
            
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            try await #require(onboarding.nameInput.isEmpty == false)
            
            // when
            await onboarding.submitForm()
            
            // then
            await #expect(mentory.onboardingFinished == true)
        }
        
        @Test func Mentory_createTodayBoard() async throws {
            // given
            let testUserName = "TEST_USER_NAME"
            await onboarding.setName(testUserName)
            
            try await #require(mentory.todayBoard == nil)
            
            // when
            await onboarding.submitForm()
            
            // then
            await #expect(mentory.todayBoard != nil)
        }
        @Test func Mentory_createSettingBoard() async throws {
            // given
            await onboarding.setName("TEST_USER_NAME")
            
            try await #require(mentory.settingBoard == nil)
            
            // when
            await onboarding.submitForm()
            
            // then
            await #expect(mentory.settingBoard != nil)
        }
        @Test func Mentory_createStatBoard() async throws {
            // given
            await onboarding.setName("TEST_USER_NAME")
            
            try await #require(mentory.statBoard == nil)
            
            // when
            await onboarding.submitForm()
            
            // then
            try await #require(mentory.statBoard != nil)
        }
    }
}


// MARK: Helphers
private func getOnboardingForTest(_ mentory: Mentory) async throws -> Onboarding {
    // create Onboarding
    try await #require(mentory.onboarding == nil)
    
    await mentory.setUp()
    
    let onBoarding = try #require(await mentory.onboarding)
    return onBoarding
}

