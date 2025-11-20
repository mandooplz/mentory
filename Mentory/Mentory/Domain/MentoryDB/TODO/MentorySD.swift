//
//  MentorySD.swift
//  Mentory
//
//  Created by 김민우 on 11/21/25.
//
import Foundation


// MARK: Domain
struct MentorySD: MentoryDBInterface {
    func updateName(_ newName: String) async throws {
        fatalError()
    }
    
    func getName() async throws -> String? {
        fatalError()
    }
}
