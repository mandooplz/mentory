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
}


extension NewRecordTicket {
    func toRecordSnapshot() -> RecordSnapshot {
        .init(
            objectID: self.id,
            recordDate: .init(self.recordDate),
            analyzedResult: self.analyzedResult,
            emotion: self.emotion
        )
    }
}
