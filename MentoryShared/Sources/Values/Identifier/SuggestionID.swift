//
//  SuggestionID.swift
//  Mentory
//
//  Created by 김민우 on 12/3/25.
//
import Foundation


// MARK: Value
public nonisolated struct SuggestionID: ObjectIdentifier {
    // MARK: core
    public let id: UUID
    
    public init(id: UUID) {
        self.id = id
    }
}

