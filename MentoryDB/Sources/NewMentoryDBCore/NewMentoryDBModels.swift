//
//  NewMentoryDBModels.swift
//  MentoryDB
//
//  Created by 김민우 on 3/4/26.
//
import Foundation
import SwiftData
import Values


// MARK: - Model
@Model
final class NewMentoryDBModel {
    @Attribute(.unique) var id: UUID

    var userName: String? = nil
    var userCharacter: MentoryCharacter? = nil

    var messageCreatedAt: Date? = nil
    var messageContent: String? = nil
    var messageCharacter: MentoryCharacter? = nil

    @Relationship var recordCreationQueue: [NewRecordTicket] = []
    @Relationship var records: [NewDailyRecordModel] = []

    init(id: UUID, userName: String? = nil) {
        self.id = id
        self.userName = userName
    }
}

@Model
final class NewRecordTicket {
    @Attribute(.unique) var id: UUID

    var recordDate: Date
    var createdAt: Date

    var analyzedResult: String
    var emotion: Emotion

    init(data: RecordData) {
        self.id = data.id
        self.recordDate = data.recordDate.rawValue
        self.createdAt = data.createdAt.rawValue
        self.analyzedResult = data.analyzedResult
        self.emotion = data.emotion
    }

    func toRecordData() -> RecordData {
        .init(
            id: id,
            recordDate: .init(recordDate),
            createdAt: .init(createdAt),
            analyzedResult: analyzedResult,
            emotion: emotion
        )
    }
}

@Model
final class NewDailyRecordModel {
    @Attribute(.unique) var id: UUID = UUID()

    @Attribute(.unique) var ticketId: UUID

    var recordDate: Date
    var createdAt: Date

    var analyzedResult: String
    var emotion: Emotion

    @Relationship var suggestions: [NewDailySuggestionModel] = []

    init(data: RecordData, suggestions: [NewDailySuggestionModel] = []) {
        self.ticketId = data.id
        self.recordDate = data.recordDate.rawValue
        self.createdAt = data.createdAt.rawValue
        self.analyzedResult = data.analyzedResult
        self.emotion = data.emotion
        self.suggestions = suggestions
    }

    func toRecordData() -> RecordData {
        .init(
            id: ticketId,
            recordDate: .init(recordDate),
            createdAt: .init(createdAt),
            analyzedResult: analyzedResult,
            emotion: emotion
        )
    }
}

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
