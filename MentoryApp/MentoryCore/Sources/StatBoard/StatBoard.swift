//
//  StatBoard.swift
//  Mentory
//
//  Created by 김민우 on 2/25/26.
//
import Foundation
import Combine
import Values
import OSLog


// MARK: object
@MainActor
public final class StatBoard: ObservableObject {
    // MARK: core
    private let logger = Logger()
    
    init(owner: Mentory) {
        self.owner = owner
    }
    
    // MARK: state
    weak var owner: Mentory?
    
    @Published public var allRecords: [RecordSnapshot] = []
    
    
    // MARK: action
    public func loadRecords() async {
        // capture
        let newMentoryDB = self.owner!.newMentoryDB

        
        // process
        let records = await newMentoryDB.records
        
        // mutate
        self.allRecords = records
    }
}
