//
//  NewDailySuggestionModel.swift
//  : DB
//
//  Created by 김민우 on 3/7/26.
//


import Foundation
import SwiftData
import Values

@Model
final class NewDailySuggestionModel {
    @Attribute(.unique) var id: UUID

    var target: UUID
    var parentRecord: UUID

    var content: String
    var status: Bool

    init(id: UUID = UUID(),
         target: UUID,
         parentRecord: UUID,
         content: String,
         status: Bool) {
        self.id = id
        self.target = target
        self.parentRecord = parentRecord
        self.content = content
        self.status = status
    }

    convenience init(data: SuggestionSnapshot) {
        self.init(
            id: data.objectID,
            target: data.suggestionID.id,
            parentRecord: data.parentRecord.id,
            content: data.content,
            status: data.isDone
        )
    }

    func toData() -> SuggestionSnapshot {
        SuggestionSnapshot(
            objectID: self.id,
            suggestionID: SuggestionID(id: target),
            parentRecord: .init(id: self.parentRecord),
            content: content,
            isDone: status
        )
    }
}
