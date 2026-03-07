//
//  NewDailySuggestion.swift
//  MentoryDB
//
//  Created by 김민우 on 3/8/26.
//

import Foundation
import Values
import OSLog


public protocol NewDailySuggestionInterface: Sendable {
    // MARK: state
    var id: UUID { get }
}


// MARK: Object
public actor NewDailySuggestion: NewDailySuggestionInterface {
    // MARK: core
    private nonisolated let logger = Logger()

    public init(id: UUID) {
        self.id = id
    }


    // MARK: state
    public nonisolated let id: UUID
}
