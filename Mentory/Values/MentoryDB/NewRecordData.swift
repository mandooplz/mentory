//
//  NewRecordData.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation


// MARK: Value
nonisolated
public struct NewRecordData: Sendable, Hashable, Codable, Equatable {
    public let id: UUID
    
    public let recordDate: Date
    public let createdAt: Date
    
    public let analyzedResult: String
    public let emotion: Emotion
}
