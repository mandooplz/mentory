//
//  NewMentoryDBInterface.swift
//  MentoryDB
//
//  Created by 김민우 on 3/7/26.
//


import Foundation
import OSLog
import SwiftData
import Values


// MARK: Interface
public protocol NewMentoryDBInterface: Actor, Sendable {
    associatedtype DailyRecordObject: NewDailyRecordInterface

    // MARK: state
    var name: String? { get set }
    var character: MentoryCharacter? { get set }
    var mentorMessage: MessageData? { get set }

    var records: [RecordData] { get }
    var recordCount: Int { get }
    var recentRecord: DailyRecordObject? { get }
    func getRecord(ticketId: UUID) -> DailyRecordObject?
    func isSameDayRecordExist(for date: MentoryDate) -> Bool

    var completedSuggestionCount: Int { get }
    func updateSuggestionStatus(targetId: UUID, isDone: Bool)

    func insertTicket(_ recordData: RecordData)
    func insertSuggestions(ticketId: UUID, suggestions: [SuggestionData]) async
    
    
    // MARK: action
    func createDailyRecords() async
}
