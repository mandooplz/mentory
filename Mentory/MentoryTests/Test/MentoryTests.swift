//
//  MentoryTests.swift
//  MentoryTests
//
//  Created by 김민우 on 11/13/25.
//
import Testing
@testable import Mentory


// MARK: Tests
@Suite("Mentory", .timeLimit(.minutes(1)))
struct MentoryTests {
    struct SetUp {
        let mentory: MentoryiOS
        init() async throws {
            self.mentory = await MentoryiOS()
        }
        
        @Test func createOnboarding() async throws {
            // given
            try await #require(mentory.onboarding == nil)
            
            // when
            await mentory.setUp()
            
            // then
            await #expect(mentory.onboarding != nil)
        }
    }
}
