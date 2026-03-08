//
//  NewRecordTicket.swift
//  MentoryDB
//
//  Created by 김민우 on 3/7/26.
//


import Foundation
import SwiftData
import Values

@Model
final class NewRecordTicket {
    @Attribute(.unique) var id: UUID

    var recordDate: Date
    var createdAt: Date

    var analyzedResult: String
    var emotion: Emotion

    init(data: RecordSnapshot) {
        self.id = data.objectID
        self.recordDate = data.recordDate.rawValue
        self.createdAt = data.createdAt.rawValue
        self.analyzedResult = data.analyzedResult
        self.emotion = data.emotion
    }

    func toRecordData() -> RecordSnapshot {
        .init(
            objectID: id,
            recordDate: .init(recordDate),
            createdAt: .init(createdAt),
            analyzedResult: analyzedResult,
            emotion: emotion
        )
    }
}
