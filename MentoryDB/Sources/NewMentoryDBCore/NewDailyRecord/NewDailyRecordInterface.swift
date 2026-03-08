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
    var id: UUID { get }
    var ticketID: UUID { get async }
    var recordID: UUID { get async }

    var recordDate: MentoryDate { get async }
    var createAt: MentoryDate { get async }

    var analyzedContent: String { get async }
    var emotion: Emotion { get async }

    var suggestionDatas: [SuggestionData] { get async }
    func getSuggestion(suggestionID: UUID) async -> SuggestionObject?

    var createSuggestionQueue: [SuggestionData] { get async }
    func insertTicket(_: [SuggestionData]) async


    // MARK: action
    func createDailySuggestions() async
}
