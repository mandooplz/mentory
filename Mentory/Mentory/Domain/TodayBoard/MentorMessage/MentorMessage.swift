//
//  MentorMessage.swift
//  Mentory
//
//  Created by 김민우 on 12/2/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
final class MentorMessage: Sendable, ObservableObject {
    // MARK: core
    init(owner: TodayBoard,
         content: String) {
        self.owner = owner
        self.content = content
    }
    
    
    // MARK: state
    weak var owner: TodayBoard?
    
    @Published private(set) var content: String
    
    
    // MARK: action
    func updateContent() async {
        fatalError()
    }
    
    
    // MARK: value
}
