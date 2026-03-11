//
//  NewDailyRecordInterface.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//


import Foundation
import OSLog
import SwiftData
import Values


// MARK: interface
public protocol NewDailyRecordInterface: Sendable {
    associatedtype SuggestionObject: NewDailySuggestionInterface

    // MARK: state
    var objectID: UUID { get }
    var recordID: RecordID { get async }

    var recordDate: MentoryDate { get async }
    var createdAt: MentoryDate { get async }

    var analyzedContent: String { get async }
    var emotion: Emotion { get async }

    var suggestionSnapshots: [SuggestionSnapshot] { get async }
    func getSuggestion(suggestionID: SuggestionID) async -> SuggestionObject?

    var createSuggestionQueue: [SuggestionSnapshot] { get async }
    func registerSnapshots(_: [SuggestionSnapshot]) async


    // MARK: action
    func createDailySuggestions() async
}
