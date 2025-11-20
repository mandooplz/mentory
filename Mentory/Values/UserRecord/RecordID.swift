//
//  RecordID.swift
//  Mentory
//
//  Created by 김민우 on 11/21/25.
//
import Foundation


// MARK: Value
nonisolated struct RecordID: Sendable, Hashable {
    // MARK: core
    let value: UUID
    init(_ value: UUID = UUID()) {
        self.value = value
    }
}
