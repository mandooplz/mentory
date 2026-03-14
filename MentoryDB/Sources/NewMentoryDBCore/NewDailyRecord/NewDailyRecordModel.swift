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
    @Attribute(.unique) var objectID: UUID = UUID()
    @Attribute(.unique) var recordID: UUID

    var recordDate: Date
    var createdAt: Date

    var analyzedResult: String
    var emotion: Emotion

    @Relationship var suggestions: [NewDailySuggestionModel] = []

    init(data: RecordSnapshot,
         suggestions: [NewDailySuggestionModel] = []) {
        self.objectID = data.objectID
        self.recordID = data.recordID.id
        self.recordDate = data.recordDate.rawValue
        self.createdAt = data.createdAt.rawValue
        self.analyzedResult = data.analyzedResult
        self.emotion = data.emotion
        self.suggestions = suggestions
    }
    
    static func descriptor(for objectID: UUID) -> FetchDescriptor<NewDailyRecordModel> {
        FetchDescriptor<NewDailyRecordModel>(
            predicate: #Predicate { $0.objectID == objectID }
        )
    }
    
    
    // MARK: operator
    var snapshot: RecordSnapshot {
        .init(
            objectID: self.objectID,
            recordID: RecordID(id: self.recordID),
            recordDate: MentoryDate(self.recordDate),
            createdAt: MentoryDate(self.createdAt),
            analyzedResult: self.analyzedResult,
            emotion: self.emotion
        )
    }
}
