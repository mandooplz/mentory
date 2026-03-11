//
//  NewDailySuggestionFake.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//

import NewMentoryDBCore
import Values
import Foundation


// MARK: fake
@MainActor
public final class NewDailySuggestionFake: NewDailySuggestionInterface {
    // MARK: core
    public init(objectID: UUID) {
        self.objectID = objectID
    }
    
    // MARK: state
    public nonisolated let objectID: UUID
    public var suggestionID: SuggestionID {
        fatalError()
    }
    
    public var content: String {
        fatalError()
    }
    public var isDone: Bool = false
    public func setDone(_ newValue: Bool) async {
        self.isDone = newValue
    }
}
