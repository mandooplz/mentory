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
    @Attribute(.unique) var objectID: UUID
    @Attribute(.unique) var suggestionID: UUID
    
    var parentRecord: UUID

    var content: String
    var status: Bool

    init(objectID: UUID,
         suggesitionID: UUID,
         parentRecord: UUID,
         content: String,
         status: Bool) {
        self.objectID = objectID
        self.suggestionID = suggesitionID
        self.parentRecord = parentRecord
        self.content = content
        self.status = status
    }

    convenience init(data: SuggestionSnapshot) {
        self.init(
            objectID: data.objectID,
            suggesitionID: data.suggestionID.id,
            parentRecord: data.parentRecord.id,
            content: data.content,
            status: data.isDone
        )
    }

    func toData() -> SuggestionSnapshot {
        SuggestionSnapshot(
            objectID: self.objectID,
            suggestionID: SuggestionID(id: suggestionID),
            parentRecord: .init(id: self.parentRecord),
            content: content,
            isDone: status
        )
    }
}
