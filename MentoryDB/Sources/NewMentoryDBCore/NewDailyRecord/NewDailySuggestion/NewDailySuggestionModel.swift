//
//  NewDailySuggestionModel.swift
//  MentoryDB
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

    var content: String
    var status: Bool

    init(id: UUID = UUID(), target: UUID, content: String, status: Bool) {
        self.id = id
        self.target = target
        self.content = content
        self.status = status
    }

    convenience init(data: SuggestionData) {
        self.init(
            id: data.id,
            target: data.target.rawValue,
            content: data.content,
            status: data.isDone
        )
    }

    func toData() -> SuggestionData {
        SuggestionData(
            id: id,
            target: SuggestionID(target),
            content: content,
            isDone: status
        )
    }
}
