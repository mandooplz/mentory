//
//  MentoryDate.swift
//  Mentory
//
//  Created by 김민우 on 12/3/25.
//
import Foundation


// MARK: Value
nonisolated
public struct MentoryDate: Sendable, Codable, Hashable {
    // MARK: core
    public let rawValue: Date
    public init(_ rawValue: Date) {
        self.rawValue = rawValue
    }
    
    // MARK: operator
}
