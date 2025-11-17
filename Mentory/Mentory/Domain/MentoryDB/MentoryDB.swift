//
//  MentoryDB.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation


// MARK: Domain
nonisolated
struct MentoryDB {
    // MARK: core
    nonisolated let id: UUID
    
    
    // MARK: flow
    @concurrent
    func updateName(_ newName: String) async throws -> Void {
        fatalError()
    }
    
    @concurrent
    func getName() async throws -> String {
        fatalError()
    }
}
