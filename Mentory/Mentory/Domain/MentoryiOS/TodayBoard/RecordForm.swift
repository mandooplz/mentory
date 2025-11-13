//
//  RecordForm.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class RecordForm: Sendable, ObservableObject {
    // MARK: core
    init(owner: TodayBoard) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    nonisolated let owner: TodayBoard
    
    
    // MARK: action
    
    
    
    // MARK: value
}
