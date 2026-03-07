//
//  NewMentoryDBModel.swift
//  MentoryDB
//
//  Created by 김민우 on 3/7/26.
//

import Foundation
import SwiftData
import Values
import OSLog


@Model
final class NewMentoryDBModel {
    // MARK: core
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
    
    
    // MARK: operator
    static let container: ModelContainer? = {
        do {
            return try ModelContainer(
                for: NewMentoryDBModel.self,
                NewRecordTicket.self,
                NewDailyRecordModel.self,
                NewDailySuggestionModel.self
            )
        } catch {
            Logger().error(
                "ModelContainer 초기화 실패: \(error.localizedDescription, privacy: .public)"
            )
            return nil
        }
    }()
    
    static func makeContextForSharedContainer() throws -> ModelContext {
        guard let container = NewMentoryDBModel.container else {
            throw NewMentoryDBError.containerUnavailable
        }

        return ModelContext(container)
    }
}
