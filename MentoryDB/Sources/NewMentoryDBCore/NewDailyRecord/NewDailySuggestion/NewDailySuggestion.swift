//
//  NewDailySuggestion.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//

import Foundation
import Values
import OSLog



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
        fatalError()
    }
    
    public var content: String {
        fatalError()
    }
    public var isDone: Bool {
        fatalError()
    }
    public func setDone(_ newValue: Bool) async {
        fatalError()
    }
}
