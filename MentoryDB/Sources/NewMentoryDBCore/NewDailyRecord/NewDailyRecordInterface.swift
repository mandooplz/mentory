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
    var recordID: UUID { get async }

    var recordDate: MentoryDate { get async }
    var createdAt: MentoryDate { get async }

    var analyzedContent: String { get async }
    var emotion: Emotion { get async }

    var suggestionDatas: [SuggestionData] { get async }
    func getSuggestion(suggestionID: UUID) async -> SuggestionObject?
    func addSuggestions(_: [SuggestionData]) async

    var createSuggestionQueue: [SuggestionData] { get async }
    func insertTicket(_: [SuggestionData]) async


    // MARK: action
    func createDailySuggestions() async
}
