//
//  NewDailyRecordFake.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//
import NewMentoryDBCore
import Values
import Foundation


// MARK: fake
public actor NewDailyRecordFake: NewDailyRecordInterface {
    // MARK: core
    public init(id: UUID) {
        self.id = id
    }


    // MARK: state
    public nonisolated let id: UUID

    public var suggestions: [SuggestionData] {
        fatalError()
    }
}
