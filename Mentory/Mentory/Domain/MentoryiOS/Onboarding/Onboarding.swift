//
//  Onboarding.swift
//  Mentory
//
//  Created by 김민우 on 11/13/25.
//
import Foundation
import Combine
import OSLog


// MARK: Object
@MainActor
final class Onboarding: Sendable, ObservableObject {
    // MARK: core
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let id = UUID()
    nonisolated let owner: MentoryiOS
    nonisolated let logger = Logger(subsystem: "Mentory", category: "Domain")
    
    var nameInput: String = ""
    
    
    // MARK: action
    func next() {
        // capture
        
        // process
        
        // mutate
    }
    
    
    // MARK: value
}
