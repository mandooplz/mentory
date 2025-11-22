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
struct DailyRecordMock: DailyRecordInterface {
    // MARK: core
    
    
    // MARK: flow
    func delete() async throws {
        fatalError()
    }
}
