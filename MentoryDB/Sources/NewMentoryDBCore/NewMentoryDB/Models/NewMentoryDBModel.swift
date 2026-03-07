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

    // SwiftData에서 특정 id를 가진 NewMentoryDBModel을 조회하기 위한 FetchDescriptor를 생성하는 함수
    static func descriptor(for id: UUID) -> FetchDescriptor<NewMentoryDBModel> {
        FetchDescriptor<NewMentoryDBModel>(
            predicate: #Predicate { $0.id == id }
        )
    }

    // SwiftData ModelContext에서 특정 NewMentoryDBModel을 조회하는 함수
    static func fetchDB(in context: ModelContext) throws -> NewMentoryDBModel {

        guard let db = try context.fetch(Self.descriptor(for: rootID)).first else {
            throw NewMentoryDBError.databaseNotFound
        }
        return db
    }


    static let rootID = UUID(
            uuidString: "00000000-0000-0000-0000-000000000000"
        )!
}
