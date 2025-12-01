//
//  MindAnalyzerTests.swift
//  Mentory
//
//  Created by 김민우 on 11/25/25.
//
import Foundation
import Testing
@testable import Mentory


// MARK: Tests
@Suite("MindAnalyzer")
struct MindAnalyzerTests {
    struct StartAnalyzing {
        let mentoryiOS: MentoryiOS
        let mindAnalyzer: MindAnalyzer
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.mindAnalyzer = try await getMindAnalyzerForTest(mentoryiOS)
        }
        
        @Test func whenTextInputIsEmpty() async throws {
            // given
            let recordForm = await mindAnalyzer.owner!
            
            await MainActor.run {
                recordForm.textInput = ""
            }
            
            try await #require(mindAnalyzer.isAnalyzeFinished == false)
            
            // when
            await mindAnalyzer.startAnalyzing()
            
            // then
            await #expect(mindAnalyzer.isAnalyzeFinished == false)
        }
    }
    struct Cacnel {
        let mentoryiOS: MentoryiOS
        let mindAnalyzer: MindAnalyzer
        init() async throws {
            self.mentoryiOS = await MentoryiOS()
            self.mindAnalyzer = try await getMindAnalyzerForTest(mentoryiOS)
        }
        
        @Test func RecordForm_removeMindAnalyzer() async throws {
            // given
            let recordForm = try #require(await mindAnalyzer.owner)
            
            try await #require(recordForm.mindAnalyzer?.id == mindAnalyzer.id)
            
            // when
            await mindAnalyzer.cancel()
            
            // then
            await #expect(recordForm.mindAnalyzer == nil)
        }
    }
}


// MARK: Helpehr
private func getMindAnalyzerForTest(_ mentoryiOS: MentoryiOS) async throws -> MindAnalyzer {
    // MentoryiOS
    await mentoryiOS.setUp()
    
    // Onboarding
    let onboarding = try #require(await mentoryiOS.onboarding)
    await onboarding.setName("테스트유저")
    await onboarding.validateInput()
    await onboarding.next()
    
    // TodayBoard
    let todayBoard = try #require(await mentoryiOS.todayBoard)
    await todayBoard.setUpForm()
    
    // RecordForm
    let recordForm = try #require(await todayBoard.recordForm)
    
    await MainActor.run {
        recordForm.titleInput = "SAMPLE_TITLE"
        recordForm.textInput = "SAMPLE_TEXT"
    }
    
    await recordForm.submit()
    
    // MindAnalyzer
    let mindAnalyzer = try #require(await recordForm.mindAnalyzer)
    return mindAnalyzer
}
