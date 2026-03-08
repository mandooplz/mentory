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
public protocol NewMentoryDBInterface: Sendable {
    associatedtype DailyRecordObject: NewDailyRecordInterface

    // MARK: state
    var id: UUID { get }

    var name: String? { get async }
    func setName(_ : String) async

    var character: MentoryCharacter? { get async }
    func setCharacter(_: MentoryCharacter) async

    var mentorMessage: MessageData? { get async }
    func setMentorMessage(_: MessageData) async

    var records: [RecordSnapshot] { get async }
    var recordCount: Int { get async }
    var recentRecord: DailyRecordObject? { get async }
    func getRecord(ticketId: UUID) async -> DailyRecordObject?
    func isSameDayRecordExist(for date: MentoryDate) async -> Bool
    func getRecord(recordID: UUID) async -> DailyRecordObject?

    var completedSuggestionCount: Int { get async }



    func insertTicket(_ recordData: RecordSnapshot) async
    func insertSuggestions(ticketId: UUID, suggestions: [SuggestionData]) async
    
    
    // MARK: action
    func createDailyRecords() async
}
