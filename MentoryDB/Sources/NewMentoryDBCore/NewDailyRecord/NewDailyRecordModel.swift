//
//  NewDailyRecordModel.swift
//  MentoryDB
//
//  Created by 김민우 on 3/7/26.
//


import Foundation
import SwiftData
import Values

@Model
final class NewDailyRecordModel {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute(.unique) var recordID: UUID
    @Attribute(.unique) var ticketId: UUID

    var recordDate: Date
    var createdAt: Date

    var analyzedResult: String
    var emotion: Emotion

    @Relationship var suggestions: [NewDailySuggestionModel] = []

    init(data: RecordSnapshot,
         suggestions: [NewDailySuggestionModel] = []) {
        self.ticketId = data.objectID
        self.recordID = data.recordID.id
        self.recordDate = data.recordDate.rawValue
        self.createdAt = data.createdAt.rawValue
        self.analyzedResult = data.analyzedResult
        self.emotion = data.emotion
        self.suggestions = suggestions
    }
    
    // MARK: value
    static func descriptor(for id: UUID) -> FetchDescriptor<NewDailyRecordModel> {
        FetchDescriptor<NewDailyRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
    }
}
