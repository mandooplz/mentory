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
    @Attribute(.unique) var recordID: UUID

    var recordDate: Date
    var createdAt: Date

    var analyzedResult: String
    var emotion: Emotion

    init(snapshot: RecordSnapshot) {
        self.id = snapshot.objectID
        self.recordID = snapshot.recordID.id
        self.recordDate = snapshot.recordDate.rawValue
        self.createdAt = snapshot.createdAt.rawValue
        self.analyzedResult = snapshot.analyzedResult
        self.emotion = snapshot.emotion
    }
}


extension NewRecordTicket {
    func toRecordSnapshot() -> RecordSnapshot {
        .init(
            objectID: self.id,
            recordID: RecordID(id: self.recordID),
            recordDate: MentoryDate(self.recordDate),
            createdAt: MentoryDate(self.createdAt),
            analyzedResult: self.analyzedResult,
            emotion: self.emotion
        )
    }
}
