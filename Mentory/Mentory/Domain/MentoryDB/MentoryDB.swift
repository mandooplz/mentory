//
//  MentoryDB.swift
//  Mentory
//
//  Created by 김민우 on 11/14/25.
//
import Foundation
import SwiftData


// MARK: Domain Interface
protocol MentoryDBInterface: Sendable {
    func updateName(_ newName: String) async throws -> Void
    func getName() async throws -> String?
}



// MARK: Domain
nonisolated
struct MentoryDB: MentoryDBInterface {
    // MARK: core
    nonisolated let id: String = "mentoryDB"
    nonisolated let nameKey = "mentoryDB.name"
    
    
    // MARK: flow
    @concurrent
    func updateName(_ newName: String) async throws -> Void {
        UserDefaults.standard.set(newName, forKey: nameKey)
    }
    
    @concurrent
    func getName() async throws -> String? {
        guard let name = UserDefaults.standard.string(forKey: nameKey) else {
           return nil
       }
       return name
    }
    
    
    // MARK: model
    @Model
    final class Model {
        @Attribute(.unique) var id: UUID
        
        var userName: String? = nil
    }
}
