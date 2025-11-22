//
//  MentorySwiftDataFlow.swift
//  Mentory
//
//  Created by 김민우 on 11/21/25.
//
import MentoryDB


// MARK: Domain
nonisolated struct MentorySwiftDataFlow: MentoryDBFlowInterface {
    @concurrent
    func updateName(_ newName: String) async throws {
        fatalError()
    }
    
    @concurrent
    func getName() async throws -> String? {
        fatalError()
    }
    
    
}
