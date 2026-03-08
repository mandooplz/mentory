//
//  NewMentoryDBConfig.swift
//
//
//  Created by 김민우 on 3/7/26.
//


import Foundation
import SwiftData
import Values
import OSLog

struct NewMentoryDBConfig {
        static let `default` = Config()

        let rootID = UUID(
            uuidString: "00000000-0000-0000-0000-000000000000"
        )!

        let container: ModelContainer?
        private let logger = Logger()

        private init() {
            do {
                self.container = try ModelContainer(
                    for: NewMentoryDBModel.self,
                    NewRecordTicket.self,
                    NewDailyRecordModel.self,
                    NewDailySuggestionModel.self
                )
            } catch {
                Logger().error(
                    "ModelContainer 초기화 실패: \(error.localizedDescription, privacy: .public)"
                )
                self.container = nil
            }
        }

        func makeContext() throws -> ModelContext {
            guard let container else {
                throw NewMentoryDBError.containerUnavailable
            }

            return ModelContext(container)
        }

        func createOnce() throws {
            let context = try makeContext()

            if try context.fetch(descriptor(for: rootID)).first == nil {
                let rootDB = NewMentoryDBModel(id: rootID)
                context.insert(rootDB)
                try context.save()
                logger.debug("Root DB 생성 완료")
            } else {
                logger.debug("기존 Root DB 재사용")
            }
        }

        func descriptor(for id: UUID) -> FetchDescriptor<NewMentoryDBModel> {
            FetchDescriptor<NewMentoryDBModel>(
                predicate: #Predicate { $0.id == id }
            )
        }

        func fetchDB(in context: ModelContext) throws -> NewMentoryDBModel {
            guard let db = try context.fetch(descriptor(for: rootID)).first else {
                throw NewMentoryDBError.databaseNotFound
            }
            return db
        }

        func updateDB(
            in context: ModelContext,
            _ update: (NewMentoryDBModel) throws -> Void
        ) throws {
            let db = try fetchDB(in: context)
            try update(db)
            try context.save()
        }
    }
