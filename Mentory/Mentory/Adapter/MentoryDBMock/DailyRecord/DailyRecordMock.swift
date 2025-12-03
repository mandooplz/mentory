//
//  DailyRecordMock.swift
//  Mentory
//
//  Created by 김민우 on 11/23/25.
//
import Foundation
import Values


// MARK: Mock
nonisolated
public struct DailyRecordMock: DailyRecordInterface {
    // MARK: core
    nonisolated let object: DailyRecordFake
    init(_ object: DailyRecordFake) {
        self.object = object
    }
    
    
    // MARK: flow
    @concurrent func getSuggestions() async throws -> [SuggestionData] {
        return await object.getSuggestions()
    }
}
