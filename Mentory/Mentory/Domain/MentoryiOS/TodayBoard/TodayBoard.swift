//
//  TodayBoard.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class TodayBoard: Sendable, ObservableObject {
    // MARK: core
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let owner: MentoryiOS
    nonisolated private let id = UUID()
    nonisolated private let logger = Logger(subsystem: "Mentory", category: "Domain")
    
    // MARK: action
    
    
    // MARK: value
}
