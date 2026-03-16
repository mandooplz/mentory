//
//  NewDailySuggestion.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//

import Foundation
import Values
import OSLog
import SwiftData



// MARK: Object
public actor NewDailySuggestion: NewDailySuggestionInterface {
    // MARK: core
    private nonisolated let logger = Logger()

    public init(objectID: UUID) {
        self.objectID = objectID
    }


    // MARK: state
    public nonisolated let objectID: UUID
    public var suggestionID: SuggestionID {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let suggestion = try fetchSuggestion(in: context)

                return SuggestionID(id: suggestion.suggestionID)
            } catch {
                logger.error("getSuggestionID 실패: \(error.localizedDescription, privacy: .public)")
                return .random
            }
        }
    }
    
    public var content: String {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let suggestion = try fetchSuggestion(in: context)

                return suggestion.content
            } catch {
                logger.error("getContent 실패: \(error.localizedDescription, privacy: .public)")
                return ""
            }
        }
    }
    public var isDone: Bool {
        get {
            do {
                let context = try NewMentoryDBConfig.default.makeContext()
                let suggestion = try fetchSuggestion(in: context)

                return suggestion.status
            } catch {
                logger.error("getIsDone 실패: \(error.localizedDescription, privacy: .public)")
                return false
            }
        }
    }
    public func setDone(_ newValue: Bool) async {
        do {
            let context = try NewMentoryDBConfig.default.makeContext()
            let suggestion = try fetchSuggestion(in: context)

            suggestion.status = newValue
            try context.save()
        } catch {
            logger.error("setDone 실패: \(error.localizedDescription, privacy: .public)")
        }
    }


    // MARK: helper
    private func fetchSuggestion(in context: ModelContext) throws -> NewDailySuggestionModel {
        let descriptor = NewDailySuggestionModel.descriptor(for: self.objectID)

        guard let suggestion = try context.fetch(descriptor).first else {
            throw NewMentoryDBError.suggestionNotFound
        }

        return suggestion
    }
}
