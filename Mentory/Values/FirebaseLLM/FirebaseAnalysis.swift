//
//  FirebaseAnalysis.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Foundation


// MARK: Value
nonisolated
public struct FirebaseAnalysis: Sendable, Hashable, Codable {
    // MARK: core
    public let mindType: Emotion
    public let empathyMessage: String
    public let actionKeywords: [String]
}
