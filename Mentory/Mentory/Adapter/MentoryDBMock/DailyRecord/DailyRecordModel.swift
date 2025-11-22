//
//  DailyRecordModel.swift
//  Mentory
//
//  Created by 김민우 on 11/23/25.
//
import Foundation
import Values
import Collections


// MARK: Object
@MainActor
final class DailyRecordModel: Sendable {
    // MARK: core
    init(owner: MentoryDBModel? = nil, createAt: Date, content: String, analyzedContent: String, emotion: Emotion) {
        self.owner = owner
        self.createAt = createAt
        self.content = content
        self.analyzedContent = analyzedContent
        self.emotion = emotion
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    weak var owner: MentoryDBModel?
    
    nonisolated let createAt: Date
    
    var content: String
    var analyzedContent: String
    
    var emotion: Emotion
    
    
    // MARK: action
    func delete() {
        fatalError()
    }
    
    
    // MARK: value
}
