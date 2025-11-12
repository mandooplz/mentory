//
//  NewCounter.swift
//  SampleCounter
//
//  Created by 김민우 on 11/12/25.
//
import Foundation
import Combine


// MARK: Object
@MainActor
final class NewCounter: Sendable, ObservableObject {
    // MARK: core
    init(owner: SampleCounter) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let owner: SampleCounter
    
    var num: Int = 0

    
    // MARK: action
    func incrementBoth() {
        // capture
        
        
        // mutate
        owner.number += 1
        self.num += 1
    }
}
